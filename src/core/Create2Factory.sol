// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ICreate2Factory} from "src/interfaces/ICreate2Factory.sol";

/// @title Create2Factory
/// @notice Provides functions for handling the smart contract deployments using 'create2'

abstract contract Create2Factory is ICreate2Factory {
	/// @dev keccak256(bytes("ContractCreation2(address,salt)"))
	bytes32 private constant CONTRACT_CREATION2_TOPIC =
		0x21f434f99e1351c2a2640a566c60c035770b1cbccde304a6218ec9852786e70a;

	function create2(bytes32 salt, bytes memory bytecode) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(salt) {
				mstore(0x00, 0x81e69d9b) // InvalidSalt()
				revert(0x1c, 0x04)
			}

			if iszero(mload(bytecode)) {
				mstore(0x00, 0x23639643) // InvalidBytecode()
				revert(0x1c, 0x04)
			}

			instance := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), salt)

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log3(0x00, 0x00, CONTRACT_CREATION2_TOPIC, instance, salt)
		}
	}

	function create2AndInitialize(
		bytes32 salt,
		bytes memory bytecode,
		bytes memory initializer
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(salt) {
				mstore(0x00, 0x81e69d9b) // InvalidSalt()
				revert(0x1c, 0x04)
			}

			if iszero(mload(bytecode)) {
				mstore(0x00, 0x23639643) // InvalidBytecode()
				revert(0x1c, 0x04)
			}

			if lt(mload(initializer), 0x04) {
				mstore(0x00, 0xadc06ae7) // InvalidInitializer()
				revert(0x1c, 0x04)
			}

			instance := create2(0x00, add(bytecode, 0x20), mload(bytecode), salt)

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log3(0x00, 0x00, CONTRACT_CREATION2_TOPIC, instance, salt)

			if iszero(call(gas(), instance, callvalue(), add(initializer, 0x20), mload(initializer), 0x00, 0x00)) {
				mstore(0x00, 0xc1ee8543) // ContractInitializationFailed()
				revert(0x1c, 0x04)
			}

			if selfbalance() {
				if iszero(call(gas(), caller(), selfbalance(), 0x00, 0x00, 0x00, 0x00)) {
					mstore(0x00, 0xf0c49d44) // RefundFailed()
					revert(0x1c, 0x04)
				}
			}
		}
	}

	function computeCreate2Address(bytes32 salt, bytes32 hash) public view virtual returns (address instance) {
		assembly ("memory-safe") {
			let ptr := mload(0x40)
			mstore(add(ptr, 0x40), hash)
			mstore(add(ptr, 0x20), salt)
			mstore(ptr, address())
			mstore8(add(ptr, 0x0b), 0xff)
			instance := shr(0x60, shl(0x60, keccak256(add(ptr, 0x0b), 0x55)))
		}
	}

	function computeCreate2Address(
		bytes32 salt,
		bytes32 hash,
		address deployer
	) public pure virtual returns (address instance) {
		assembly ("memory-safe") {
			let ptr := mload(0x40)
			mstore(add(ptr, 0x40), hash)
			mstore(add(ptr, 0x20), salt)
			mstore(ptr, shr(0x60, shl(0x60, deployer)))
			mstore8(add(ptr, 0x0b), 0xff)
			instance := shr(0x60, shl(0x60, keccak256(add(ptr, 0x0b), 0x55)))
		}
	}
}

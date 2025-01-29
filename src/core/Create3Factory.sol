// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ICreate3Factory} from "src/interfaces/ICreate3Factory.sol";

/// @title Create3Factory
/// @notice Provides functions for handling the smart contract deployments using 'create3'

abstract contract Create3Factory is ICreate3Factory {
	/// @dev keccak256(bytes("ContractCreation3(address,salt)"))
	bytes32 private constant CONTRACT_CREATION3_TOPIC =
		0xc546de956d694668f3bd03a86a96c4f00a8aee2dd06523a2f4b120ac3b03d5b8;

	uint256 private constant PROXY_BYTECODE = 0x67363d3d37363d34f03d5260086018f3;

	bytes32 private constant PROXY_BYTECODE_HASH = 0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

	function create3(bytes32 salt, bytes memory bytecode) public payable virtual returns (address instance) {
		instance = computeCreate3Address(salt);

		assembly ("memory-safe") {
			if iszero(iszero(extcodesize(instance))) {
				mstore(0x00, 0xc5644373) // ContractAlreadyExists(address)
				mstore(0x20, instance)
				revert(0x1c, 0x24)
			}

			if iszero(salt) {
				mstore(0x00, 0x81e69d9b) // InvalidSalt()
				revert(0x1c, 0x04)
			}

			if iszero(mload(bytecode)) {
				mstore(0x00, 0x23639643) // InvalidBytecode()
				revert(0x1c, 0x04)
			}

			log3(0x00, 0x00, CONTRACT_CREATION3_TOPIC, instance, salt)

			mstore(0x00, PROXY_BYTECODE)

			let proxy := create2(0x00, 0x10, 0x10, salt)

			if iszero(extcodesize(proxy)) {
				mstore(0x00, 0xd49e7d74) // ProxyCreationFailed()
				revert(0x1c, 0x04)
			}

			mstore(0x14, proxy)
			mstore(0x00, 0xd694)
			mstore8(0x34, 0x01)
			instance := keccak256(0x1e, 0x17)

			if iszero(
				and(
					iszero(iszero(extcodesize(instance))),
					call(gas(), proxy, callvalue(), add(bytecode, 0x20), mload(bytecode), 0x00, 0x00)
				)
			) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}
		}
	}

	function create3AndInitialize(
		bytes32 salt,
		bytes memory bytecode,
		bytes memory initializer
	) public payable virtual returns (address instance) {
		instance = computeCreate3Address(salt);

		assembly ("memory-safe") {
			if iszero(iszero(extcodesize(instance))) {
				mstore(0x00, 0xc5644373) // ContractAlreadyExists(address)
				mstore(0x20, instance)
				revert(0x1c, 0x24)
			}

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

			log3(0x00, 0x00, CONTRACT_CREATION3_TOPIC, instance, salt)

			mstore(0x00, PROXY_BYTECODE)

			let proxy := create2(0x00, 0x10, 0x10, salt)

			if iszero(extcodesize(proxy)) {
				mstore(0x00, 0xd49e7d74) // ProxyCreationFailed()
				revert(0x1c, 0x04)
			}

			mstore(0x14, proxy)
			mstore(0x00, 0xd694)
			mstore8(0x34, 0x01)
			instance := keccak256(0x1e, 0x17)

			if iszero(
				and(
					iszero(iszero(extcodesize(instance))),
					call(gas(), proxy, 0x00, add(bytecode, 0x20), mload(bytecode), 0x00, 0x00)
				)
			) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

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

	function computeCreate3Address(bytes32 salt) public view virtual returns (address instance) {
		assembly ("memory-safe") {
			let ptr := mload(0x40)
			mstore(0x00, address())
			mstore8(0x0b, 0xff)
			mstore(0x20, salt)
			mstore(0x40, PROXY_BYTECODE_HASH)
			mstore(0x14, keccak256(0x0b, 0x55))
			mstore(0x40, ptr)
			mstore(0x00, 0xd694)
			mstore8(0x34, 0x01)
			instance := shr(0x60, shl(0x60, keccak256(0x1e, 0x17)))
		}
	}
}

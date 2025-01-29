// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ICreateFactory} from "src/interfaces/ICreateFactory.sol";

/// @title CreateFactory
/// @notice Provides functions for handling the smart contract deployments using 'create'

abstract contract CreateFactory is ICreateFactory {
	/// @dev keccak256(bytes("ContractCreation(address)"))
	bytes32 private constant CONTRACT_CREATION_TOPIC =
		0x4db17dd5e4732fb6da34a148104a592783ca119a1e7bb8829eba6cbadef0b511;

	function create(bytes memory bytecode) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(mload(bytecode)) {
				mstore(0x00, 0x23639643) // InvalidBytecode()
				revert(0x1c, 0x04)
			}

			instance := create(callvalue(), add(bytecode, 0x20), mload(bytecode))

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log2(0x00, 0x00, CONTRACT_CREATION_TOPIC, instance)
		}
	}

	function createAndInitialize(
		bytes memory bytecode,
		bytes memory initializer
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(mload(bytecode)) {
				mstore(0x00, 0x23639643) // InvalidBytecode()
				revert(0x1c, 0x04)
			}

			if lt(mload(initializer), 0x04) {
				mstore(0x00, 0xadc06ae7) // InvalidInitializer()
				revert(0x1c, 0x04)
			}

			instance := create(0x00, add(bytecode, 0x20), mload(bytecode))

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log2(0x00, 0x00, CONTRACT_CREATION_TOPIC, instance)

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ICloneFactory} from "src/interfaces/ICloneFactory.sol";

/// @title CloneFactory
/// @notice Provides functions for handling the deployments of minimal proxy contracts

abstract contract CloneFactory is ICloneFactory {
	/// @dev keccak256(bytes("CloneCreation(address,address)"))
	bytes32 private constant CLONE_CREATION_TOPIC = 0xe7f24851eadf888035617feb6553a054cc5dfe0550a298bd674568659c1f9de6;

	/// @dev keccak256(bytes("CloneDeterministicCreation(address,address,bytes32)"))
	bytes32 private constant CLONE_DETERMINISTIC_CREATION_TOPIC =
		0x686a328040fa58fa604bcb7898254dcfe8eb0e0b1ed928998ee15842fedb3880;

	function clone(address implementation) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(extcodesize(implementation)) {
				mstore(0x00, 0x68155f9a) // InvalidImplementation()
				revert(0x1c, 0x04)
			}

			mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
			mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

			instance := create(callvalue(), 0x09, 0x37)

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log3(0x00, 0x00, CLONE_CREATION_TOPIC, instance, implementation)
		}
	}

	function cloneAndInitialize(
		address implementation,
		bytes memory initializer
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(extcodesize(implementation)) {
				mstore(0x00, 0x68155f9a) // InvalidImplementation()
				revert(0x1c, 0x04)
			}

			if lt(mload(initializer), 0x04) {
				mstore(0x00, 0xadc06ae7) // InvalidInitializer()
				revert(0x1c, 0x04)
			}

			mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
			mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

			instance := create(0x00, 0x09, 0x37)

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log3(0x00, 0x00, CLONE_CREATION_TOPIC, instance, implementation)

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

	function cloneDeterministic(
		bytes32 salt,
		address implementation
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(salt) {
				mstore(0x00, 0x81e69d9b) // InvalidSalt()
				revert(0x1c, 0x04)
			}

			if iszero(extcodesize(implementation)) {
				mstore(0x00, 0x68155f9a) // InvalidImplementation()
				revert(0x1c, 0x04)
			}

			mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
			mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

			instance := create2(callvalue(), 0x09, 0x37, salt)

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log4(0x00, 0x00, CLONE_DETERMINISTIC_CREATION_TOPIC, instance, implementation, salt)
		}
	}

	function cloneDeterministicAndInitialize(
		bytes32 salt,
		address implementation,
		bytes memory initializer
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(salt) {
				mstore(0x00, 0x81e69d9b) // InvalidSalt()
				revert(0x1c, 0x04)
			}

			if iszero(extcodesize(implementation)) {
				mstore(0x00, 0x68155f9a) // InvalidImplementation()
				revert(0x1c, 0x04)
			}

			if lt(mload(initializer), 0x04) {
				mstore(0x00, 0xadc06ae7) // InvalidInitializer()
				revert(0x1c, 0x04)
			}

			mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
			mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

			instance := create2(0x00, 0x09, 0x37, salt)

			if iszero(extcodesize(instance)) {
				mstore(0x00, 0xa28c2473) // ContractCreationFailed()
				revert(0x1c, 0x04)
			}

			log4(0x00, 0x00, CLONE_DETERMINISTIC_CREATION_TOPIC, instance, implementation, salt)

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

	function computeDeterministicAddress(
		bytes32 salt,
		address implementation
	) public view virtual returns (address instance) {
		assembly ("memory-safe") {
			let ptr := mload(0x40)
			mstore(add(ptr, 0x38), address())
			mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
			mstore(add(ptr, 0x14), shr(0x60, shl(0x60, implementation)))
			mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
			mstore(add(ptr, 0x58), salt)
			mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
			instance := shr(0x60, shl(0x60, keccak256(add(ptr, 0x43), 0x55)))
		}
	}

	function computeDeterministicAddress(
		bytes32 salt,
		address implementation,
		address deployer
	) public pure virtual returns (address instance) {
		assembly ("memory-safe") {
			let ptr := mload(0x40)
			mstore(add(ptr, 0x38), shr(0x60, shl(0x60, deployer)))
			mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
			mstore(add(ptr, 0x14), shr(0x60, shl(0x60, implementation)))
			mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
			mstore(add(ptr, 0x58), salt)
			mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
			instance := shr(0x60, shl(0x60, keccak256(add(ptr, 0x43), 0x55)))
		}
	}
}

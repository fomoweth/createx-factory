// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ICreateXFactory} from "src/interfaces/ICreateXFactory.sol";
import {CloneFactory as Clone} from "src/core/CloneFactory.sol";
import {CreateFactory as Create} from "src/core/CreateFactory.sol";
import {Create2Factory as Create2} from "src/core/Create2Factory.sol";
import {Create3Factory as Create3} from "src/core/Create3Factory.sol";

/// @title CreateXFactory
/// @notice Manages the creation of smart contracts using 'create', 'create2', 'create3' and 'minimal proxy pattern'

contract CreateXFactory is ICreateXFactory, Clone, Create, Create2, Create3 {
	uint256 internal constant CREATION_TYPE_CREATE = 1;
	uint256 internal constant CREATION_TYPE_CREATE2 = 2;
	uint256 internal constant CREATION_TYPE_CREATE3 = 3;
	uint256 internal constant CREATION_TYPE_CLONE = 4;
	uint256 internal constant CREATION_TYPE_CLONE_DETERMINISTIC = 5;

	function deploy(
		uint256 creationType,
		bytes32 salt,
		bytes memory bytecode
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if or(iszero(creationType), gt(creationType, CREATION_TYPE_CLONE_DETERMINISTIC)) {
				mstore(0x00, 0xbfa05391) // UnsupportedCreationType(uint256)
				mstore(0x20, creationType)
				revert(0x1c, 0x24)
			}
		}

		if (creationType == CREATION_TYPE_CREATE) {
			return create(bytecode);
		} else if (creationType == CREATION_TYPE_CREATE2) {
			return create2(salt, bytecode);
		} else if (creationType == CREATION_TYPE_CREATE3) {
			return create3(salt, bytecode);
		} else if (creationType == CREATION_TYPE_CLONE) {
			return clone(parseImplementation(bytecode));
		} else if (creationType == CREATION_TYPE_CLONE_DETERMINISTIC) {
			return cloneDeterministic(salt, parseImplementation(bytecode));
		}
	}

	function deployAndInitialize(
		uint256 creationType,
		bytes32 salt,
		bytes memory bytecode,
		bytes memory initializer
	) public payable virtual returns (address instance) {
		assembly ("memory-safe") {
			if or(iszero(creationType), gt(creationType, CREATION_TYPE_CLONE_DETERMINISTIC)) {
				mstore(0x00, 0xbfa05391) // UnsupportedCreationType(uint256)
				mstore(0x20, creationType)
				revert(0x1c, 0x24)
			}
		}

		if (creationType == CREATION_TYPE_CREATE) {
			return createAndInitialize(bytecode, initializer);
		} else if (creationType == CREATION_TYPE_CREATE2) {
			return create2AndInitialize(salt, bytecode, initializer);
		} else if (creationType == CREATION_TYPE_CREATE3) {
			return create3AndInitialize(salt, bytecode, initializer);
		} else if (creationType == CREATION_TYPE_CLONE) {
			return cloneAndInitialize(parseImplementation(bytecode), initializer);
		} else if (creationType == CREATION_TYPE_CLONE_DETERMINISTIC) {
			return cloneDeterministicAndInitialize(salt, parseImplementation(bytecode), initializer);
		}
	}

	function computeAddress(
		uint256 creationType,
		bytes32 salt,
		bytes32 hash
	) public view virtual returns (address instance) {
		assembly ("memory-safe") {
			if iszero(
				or(
					or(eq(creationType, CREATION_TYPE_CREATE2), eq(creationType, CREATION_TYPE_CREATE3)),
					eq(creationType, CREATION_TYPE_CLONE_DETERMINISTIC)
				)
			) {
				mstore(0x00, 0xbfa05391) // UnsupportedCreationType(uint256)
				mstore(0x20, creationType)
				revert(0x1c, 0x24)
			}
		}

		if (creationType == CREATION_TYPE_CREATE2) {
			return computeCreate2Address(salt, hash);
		} else if (creationType == CREATION_TYPE_CREATE3) {
			return computeCreate3Address(salt);
		} else if (creationType == CREATION_TYPE_CLONE_DETERMINISTIC) {
			return computeDeterministicAddress(salt, parseImplementation(hash));
		}
	}

	function parseImplementation(bytes memory bytecode) internal pure virtual returns (address implementation) {
		assembly ("memory-safe") {
			implementation := shr(0x60, shl(0x60, mload(add(bytecode, 0x20))))
		}
	}

	function parseImplementation(bytes32 hash) internal pure virtual returns (address implementation) {
		assembly ("memory-safe") {
			implementation := shr(0x60, shl(0x60, hash))
		}
	}

	receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {FactoryTest} from "test/shared/FactoryTest.sol";

contract CreateXFactoryTest is FactoryTest {
	function test_deploy() public impersonate(DEPLOYER) {
		address predicted;
		address instance;

		vm.deal(DEPLOYER, CALL_VALUE);

		revertToState();

		predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		instance = createXFactory.deploy{value: CALL_VALUE}(CREATION_TYPE_CREATE, DEFAULT_SALT, DEFAULT_BYTECODE);
		assertEq(predicted, instance);

		revertToState();

		predicted = createXFactory.computeAddress(CREATION_TYPE_CREATE2, DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
		instance = createXFactory.deploy{value: CALL_VALUE}(CREATION_TYPE_CREATE2, DEFAULT_SALT, DEFAULT_BYTECODE);
		assertEq(predicted, instance);

		revertToState();

		predicted = createXFactory.computeAddress(CREATION_TYPE_CREATE3, DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
		instance = createXFactory.deploy{value: CALL_VALUE}(CREATION_TYPE_CREATE3, DEFAULT_SALT, DEFAULT_BYTECODE);
		assertEq(predicted, instance);

		revertToState();

		predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		instance = createXFactory.deploy{value: CALL_VALUE}(
			CREATION_TYPE_CLONE,
			DEFAULT_SALT,
			abi.encode(address(mockTarget))
		);
		assertEq(predicted, instance);

		revertToState();

		predicted = createXFactory.computeAddress(
			CREATION_TYPE_CLONE_DETERMINISTIC,
			DEFAULT_SALT,
			bytes32(uint256(uint160(address(mockTarget))))
		);
		instance = createXFactory.deploy{value: CALL_VALUE}(
			CREATION_TYPE_CLONE_DETERMINISTIC,
			DEFAULT_SALT,
			abi.encode(address(mockTarget))
		);
		assertEq(predicted, instance);
	}

	function test_deploy_revertsWithUnsupportedCreationType(uint8 creationType) public {
		if (creationType != 0) creationType = uint8(bound(creationType, 6, type(uint8).max));

		vm.expectRevert(abi.encodeWithSelector(UnsupportedCreationType.selector, creationType));
		createXFactory.deploy{value: CALL_VALUE}(creationType, DEFAULT_SALT, DEFAULT_BYTECODE);
	}

	function test_computeAddress_revertsWithUnsupportedCreationType(uint8 creationType) public {
		vm.assume(
			creationType != CREATION_TYPE_CREATE2 &&
				creationType != CREATION_TYPE_CREATE3 &&
				creationType != CREATION_TYPE_CLONE_DETERMINISTIC
		);

		vm.expectRevert(abi.encodeWithSelector(UnsupportedCreationType.selector, creationType));
		createXFactory.computeAddress(creationType, DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
	}

	function test_deployAndInitialize() public impersonate(DEPLOYER) {
		address predicted;
		address instance;

		vm.deal(DEPLOYER, CALL_VALUE);

		revertToState();

		predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		instance = createXFactory.deployAndInitialize{value: CALL_VALUE}(
			CREATION_TYPE_CREATE,
			DEFAULT_SALT,
			DEFAULT_BYTECODE,
			DEFAULT_INITIALIZER
		);
		assertEq(predicted, instance);

		revertToState();

		predicted = createXFactory.computeAddress(CREATION_TYPE_CREATE2, DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
		instance = createXFactory.deployAndInitialize{value: CALL_VALUE}(
			CREATION_TYPE_CREATE2,
			DEFAULT_SALT,
			DEFAULT_BYTECODE,
			DEFAULT_INITIALIZER
		);
		assertEq(predicted, instance);

		revertToState();

		predicted = createXFactory.computeAddress(CREATION_TYPE_CREATE3, DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
		instance = createXFactory.deployAndInitialize{value: CALL_VALUE}(
			CREATION_TYPE_CREATE3,
			DEFAULT_SALT,
			DEFAULT_BYTECODE,
			DEFAULT_INITIALIZER
		);
		assertEq(predicted, instance);

		revertToState();

		predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		instance = createXFactory.deployAndInitialize{value: CALL_VALUE}(
			CREATION_TYPE_CLONE,
			DEFAULT_SALT,
			abi.encode(address(mockTarget)),
			DEFAULT_INITIALIZER
		);
		assertEq(predicted, instance);

		revertToState();

		predicted = createXFactory.computeAddress(
			CREATION_TYPE_CLONE_DETERMINISTIC,
			DEFAULT_SALT,
			bytes32(uint256(uint160(address(mockTarget))))
		);
		instance = createXFactory.deployAndInitialize{value: CALL_VALUE}(
			CREATION_TYPE_CLONE_DETERMINISTIC,
			DEFAULT_SALT,
			abi.encode(address(mockTarget)),
			DEFAULT_INITIALIZER
		);
		assertEq(predicted, instance);
	}

	function test_deployAndInitialize_revertsWithUnsupportedCreationType(uint8 creationType) public {
		if (creationType != 0) creationType = uint8(bound(creationType, 6, type(uint8).max));

		vm.expectRevert(abi.encodeWithSelector(UnsupportedCreationType.selector, creationType));
		createXFactory.deployAndInitialize{value: CALL_VALUE}(
			creationType,
			DEFAULT_SALT,
			DEFAULT_BYTECODE,
			DEFAULT_INITIALIZER
		);
	}

	function test_parseImplementation() public virtual {
		bytes memory bytecode = abi.encode(address(mockTarget));
		bytes32 bytecodeHash = bytes32(uint256(uint160(address(mockTarget))));

		assertEq(parseImplementation(bytecode), address(mockTarget));
		assertEq(parseImplementation(bytecodeHash), address(mockTarget));
	}

	function parseImplementation(bytes memory bytecode) internal pure returns (address implementation) {
		assembly ("memory-safe") {
			implementation := shr(0x60, shl(0x60, mload(add(bytecode, 0x20))))
		}
	}

	function parseImplementation(bytes32 hash) internal pure returns (address implementation) {
		assembly ("memory-safe") {
			implementation := shr(0x60, shl(0x60, hash))
		}
	}
}

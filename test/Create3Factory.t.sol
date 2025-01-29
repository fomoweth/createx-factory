// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {FactoryTest} from "test/shared/FactoryTest.sol";

contract Create3FactoryTest is FactoryTest {
	function test_create3() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeCreate3Address(DEFAULT_SALT);
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, false, false);
		emit ContractCreation3(predicted, DEFAULT_SALT);

		address instance = createXFactory.create3{value: CALL_VALUE}(DEFAULT_SALT, DEFAULT_BYTECODE);

		assertEq(instance, predicted);
		assertEq(instance.balance, CALL_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), 0);
	}

	function test_create3_revertsWithContractAlreadyExists() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeCreate3Address(DEFAULT_SALT);
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, false, false);
		emit ContractCreation3(predicted, DEFAULT_SALT);

		address instance = createXFactory.create3(DEFAULT_SALT, DEFAULT_BYTECODE);

		vm.expectRevert(abi.encodeWithSelector(ContractAlreadyExists.selector, instance));
		createXFactory.create3{value: CALL_VALUE}(DEFAULT_SALT, DEFAULT_BYTECODE);
	}

	function test_create3_revertsWithInvalidSalt() public {
		vm.expectRevert(InvalidSalt.selector);
		createXFactory.create3(0, DEFAULT_BYTECODE);
	}

	function test_create3_revertsWithInvalidBytecode() public {
		vm.expectRevert(InvalidBytecode.selector);
		createXFactory.create3(DEFAULT_SALT, emptyBytes());
	}

	function test_create3AndInitialize() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeCreate3Address(DEFAULT_SALT);
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, true, true);
		emit ContractCreation3(predicted, DEFAULT_SALT);

		vm.expectEmit(true, true, false, false);
		emit Initialized(CALL_VALUE, INITIAL_VALUE);

		address instance = createXFactory.create3AndInitialize{value: CALL_VALUE}(
			DEFAULT_SALT,
			DEFAULT_BYTECODE,
			DEFAULT_INITIALIZER
		);

		assertEq(instance, predicted);
		assertEq(instance.balance, REFUND_VALUE);
		assertEq(DEPLOYER.balance, REFUND_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), INITIAL_VALUE);
	}

	function test_create3AndInitialize_revertsWithInvalidSalt() public {
		vm.expectRevert(InvalidSalt.selector);
		createXFactory.create3AndInitialize(0, DEFAULT_BYTECODE, DEFAULT_INITIALIZER);
	}

	function test_create3AndInitialize_revertsWithInvalidBytecode() public {
		vm.expectRevert(InvalidBytecode.selector);
		createXFactory.create3AndInitialize(DEFAULT_SALT, emptyBytes(), DEFAULT_INITIALIZER);
	}

	function test_create3AndInitialize_revertsWithInvalidInitializer() public {
		vm.expectRevert(InvalidInitializer.selector);
		createXFactory.create3AndInitialize(DEFAULT_SALT, DEFAULT_BYTECODE, vm.randomBytes(3));
	}
}

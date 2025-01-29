// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {FactoryTest} from "test/shared/FactoryTest.sol";

contract CreateFactoryTest is FactoryTest {
	function test_create() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		assertFalse(isContract(predicted));

		vm.expectEmit(true, false, false, false);
		emit ContractCreation(predicted);

		address instance = createXFactory.create{value: CALL_VALUE}(DEFAULT_BYTECODE);

		assertEq(instance, predicted);
		assertEq(instance.balance, CALL_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), 0);
	}

	function test_create_revertsWithInvalidBytecode() public {
		vm.expectRevert(InvalidBytecode.selector);
		createXFactory.create(emptyBytes());
	}

	function test_createAndInitialize() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		assertFalse(isContract(predicted));

		vm.expectEmit(true, false, false, false);
		emit ContractCreation(predicted);
		vm.expectEmit(true, true, false, false);
		emit Initialized(CALL_VALUE, INITIAL_VALUE);

		address instance = createXFactory.createAndInitialize{value: CALL_VALUE}(DEFAULT_BYTECODE, DEFAULT_INITIALIZER);

		assertEq(instance, predicted);
		assertEq(instance.balance, REFUND_VALUE);
		assertEq(DEPLOYER.balance, REFUND_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), INITIAL_VALUE);
	}

	function test_createAndInitialize_revertsWithInvalidBytecode() public {
		vm.expectRevert(InvalidBytecode.selector);
		createXFactory.createAndInitialize(emptyBytes(), DEFAULT_INITIALIZER);
	}

	function test_createAndInitialize_revertsWithInvalidInitializer() public {
		vm.expectRevert(InvalidInitializer.selector);
		createXFactory.createAndInitialize(DEFAULT_BYTECODE, vm.randomBytes(3));
	}
}

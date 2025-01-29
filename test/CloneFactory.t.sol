// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {FactoryTest} from "test/shared/FactoryTest.sol";

contract CloneFactoryTest is FactoryTest {
	function test_clone() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, false, false);
		emit CloneCreation(predicted, address(mockTarget));

		address instance = createXFactory.clone{value: CALL_VALUE}(address(mockTarget));

		assertEq(instance, predicted);
		assertEq(instance.balance, CALL_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), 0);
	}

	function test_clone_revertsWithInvalidImplementation() public {
		vm.expectRevert(InvalidImplementation.selector);
		createXFactory.clone(address(0));
	}

	function test_cloneAndInitialize() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = vm.computeCreateAddress(address(createXFactory), vm.getNonce(address(createXFactory)));
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, false, false);
		emit CloneCreation(predicted, address(mockTarget));

		vm.expectEmit(true, true, false, false);
		emit Initialized(CALL_VALUE, INITIAL_VALUE);

		address instance = createXFactory.cloneAndInitialize{value: CALL_VALUE}(
			address(mockTarget),
			DEFAULT_INITIALIZER
		);

		assertEq(instance, predicted);
		assertEq(instance.balance, REFUND_VALUE);
		assertEq(DEPLOYER.balance, REFUND_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), INITIAL_VALUE);
	}

	function test_cloneAndInitialize_revertsWithInvalidImplementation() public {
		vm.expectRevert(InvalidImplementation.selector);
		createXFactory.cloneAndInitialize(address(0), DEFAULT_INITIALIZER);
	}

	function test_cloneAndInitialize_revertsWithInvalidInitializer() public {
		vm.expectRevert(InvalidInitializer.selector);
		createXFactory.cloneAndInitialize(address(mockTarget), vm.randomBytes(3));
	}

	function test_cloneDeterministic() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeDeterministicAddress(DEFAULT_SALT, address(mockTarget));
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, true, false);
		emit CloneDeterministicCreation(predicted, address(mockTarget), DEFAULT_SALT);

		address instance = createXFactory.cloneDeterministic{value: CALL_VALUE}(DEFAULT_SALT, address(mockTarget));

		assertEq(instance, predicted);
		assertEq(instance.balance, CALL_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), 0);
	}

	function test_cloneDeterministic_revertsWithInvalidSalt() public {
		vm.expectRevert(InvalidSalt.selector);
		createXFactory.cloneDeterministic(0, address(mockTarget));
	}

	function test_cloneDeterministic_revertsWithInvalidImplementation() public {
		vm.expectRevert(InvalidImplementation.selector);
		createXFactory.cloneDeterministic(DEFAULT_SALT, address(0));
	}

	function test_cloneDeterministicAndInitialize() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeDeterministicAddress(DEFAULT_SALT, address(mockTarget));
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, true, false);
		emit CloneDeterministicCreation(predicted, address(mockTarget), DEFAULT_SALT);

		vm.expectEmit(true, true, false, false);
		emit Initialized(CALL_VALUE, INITIAL_VALUE);

		address instance = createXFactory.cloneDeterministicAndInitialize{value: CALL_VALUE}(
			DEFAULT_SALT,
			address(mockTarget),
			DEFAULT_INITIALIZER
		);

		assertEq(instance, predicted);
		assertEq(instance.balance, REFUND_VALUE);
		assertEq(DEPLOYER.balance, REFUND_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), INITIAL_VALUE);
	}

	function test_cloneDeterministicAndInitialize_revertsWithInvalidSalt() public {
		vm.expectRevert(InvalidSalt.selector);
		createXFactory.cloneDeterministicAndInitialize(0, address(mockTarget), DEFAULT_INITIALIZER);
	}

	function test_cloneDeterministicAndInitialize_revertsWithInvalidImplementation() public {
		vm.expectRevert(InvalidImplementation.selector);
		createXFactory.cloneDeterministicAndInitialize(DEFAULT_SALT, address(0), DEFAULT_INITIALIZER);
	}

	function test_cloneDeterministicAndInitialize_revertsWithInvalidInitializer() public {
		vm.expectRevert(InvalidInitializer.selector);
		createXFactory.cloneDeterministicAndInitialize(DEFAULT_SALT, address(mockTarget), vm.randomBytes(3));
	}
}

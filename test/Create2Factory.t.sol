// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {FactoryTest} from "test/shared/FactoryTest.sol";

contract Create2FactoryTest is FactoryTest {
	function test_create2() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeCreate2Address(DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, false, false);
		emit ContractCreation2(predicted, DEFAULT_SALT);

		address instance = createXFactory.create2{value: CALL_VALUE}(DEFAULT_SALT, DEFAULT_BYTECODE);

		assertEq(instance, predicted);
		assertEq(instance.balance, CALL_VALUE);
		assertEq(constructValue(instance), CONSTRUCT_VALUE);
		assertEq(fetchValue(instance), 0);
	}

	function test_create2_revertsWithInvalidSalt() public {
		vm.expectRevert(InvalidSalt.selector);
		createXFactory.create2(0, DEFAULT_BYTECODE);
	}

	function test_create2_revertsWithInvalidBytecode() public {
		vm.expectRevert(InvalidBytecode.selector);
		createXFactory.create2(DEFAULT_SALT, emptyBytes());
	}

	function test_create2AndInitialize() public impersonate(DEPLOYER) {
		vm.deal(DEPLOYER, CALL_VALUE);

		address predicted = createXFactory.computeCreate2Address(DEFAULT_SALT, DEFAULT_BYTECODE_HASH);
		assertFalse(isContract(predicted));

		vm.expectEmit(true, true, false, false);
		emit ContractCreation2(predicted, DEFAULT_SALT);

		vm.expectEmit(true, true, false, false);
		emit Initialized(CALL_VALUE, INITIAL_VALUE);

		address instance = createXFactory.create2AndInitialize{value: CALL_VALUE}(
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

	function test_create2AndInitialize_revertsWithInvalidSalt() public {
		vm.expectRevert(InvalidSalt.selector);
		createXFactory.create2AndInitialize(0, DEFAULT_BYTECODE, DEFAULT_INITIALIZER);
	}

	function test_create2AndInitialize_revertsWithInvalidBytecode() public {
		vm.expectRevert(InvalidBytecode.selector);
		createXFactory.create2AndInitialize(DEFAULT_SALT, emptyBytes(), DEFAULT_INITIALIZER);
	}

	function test_create2AndInitialize_revertsWithInvalidInitializer() public {
		vm.expectRevert(InvalidInitializer.selector);
		createXFactory.create2AndInitialize(DEFAULT_SALT, DEFAULT_BYTECODE, vm.randomBytes(3));
	}
}

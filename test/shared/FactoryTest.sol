// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {CreateXFactory} from "src/CreateXFactory.sol";

import {MockTarget} from "test/shared/mocks/MockTarget.sol";
import {EventsAndErrors} from "./EventsAndErrors.sol";

abstract contract FactoryTest is Test, EventsAndErrors {
	uint256 internal constant MAX_UINT256 = (1 << 256) - 1;

	uint256 internal constant CREATION_TYPE_CREATE = 1;
	uint256 internal constant CREATION_TYPE_CREATE2 = 2;
	uint256 internal constant CREATION_TYPE_CREATE3 = 3;
	uint256 internal constant CREATION_TYPE_CLONE = 4;
	uint256 internal constant CREATION_TYPE_CLONE_DETERMINISTIC = 5;

	address internal immutable DEPLOYER = makeAddr("Deployer");

	bytes32 internal immutable DEFAULT_SALT = keccak256("DEFAULT_SALT");

	CreateXFactory internal createXFactory;

	MockTarget internal mockTarget;

	bytes internal DEFAULT_BYTECODE;
	bytes32 internal DEFAULT_BYTECODE_HASH;
	bytes internal DEFAULT_INITIALIZER;

	uint256 internal CALL_VALUE;
	uint256 internal REFUND_VALUE;
	uint256 internal CONSTRUCT_VALUE;
	uint256 internal INITIAL_VALUE;

	uint256 internal snapshotId = MAX_UINT256;

	modifier impersonate(address account) {
		vm.startPrank(account);
		_;
		vm.stopPrank();
	}

	function setUp() public virtual {
		vm.label(address(createXFactory = new CreateXFactory()), "CreateXFactory");

		if ((CALL_VALUE = vm.randomUint(0, 100 ether)) & 1 != 0) --CALL_VALUE;
		REFUND_VALUE = CALL_VALUE / 2;

		CONSTRUCT_VALUE = vm.randomUint();
		INITIAL_VALUE = vm.randomUint();

		vm.label(address(mockTarget = new MockTarget(CONSTRUCT_VALUE)), "MockTarget");

		DEFAULT_BYTECODE = bytes.concat(type(MockTarget).creationCode, abi.encode(CONSTRUCT_VALUE));
		DEFAULT_BYTECODE_HASH = keccak256(DEFAULT_BYTECODE);
		DEFAULT_INITIALIZER = abi.encodeCall(MockTarget.initialize, (INITIAL_VALUE));
	}

	function revertToState() internal {
		if (snapshotId != MAX_UINT256) vm.revertToState(snapshotId);
		snapshotId = vm.snapshotState();
	}

	function constructValue(address instance) internal view returns (uint256) {
		return MockTarget(instance).constructValue();
	}

	function fetchValue(address instance) internal view returns (uint256) {
		return MockTarget(instance).getValue();
	}

	function isContract(address target) internal view returns (bool flag) {
		assembly ("memory-safe") {
			flag := iszero(iszero(extcodesize(target)))
		}
	}

	function emptyBytes() internal pure returns (bytes calldata data) {
		assembly ("memory-safe") {
			data.offset := 0x00
			data.length := 0x00
		}
	}
}

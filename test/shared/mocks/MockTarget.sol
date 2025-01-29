// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MockTarget {
	event Initialized(uint256 indexed callValue, uint256 indexed initialValue);

	uint256 public immutable constructValue;
	uint256 public value;

	constructor(uint256 initialValue) payable {
		constructValue = initialValue;
	}

	function initialize(uint256 initialValue) external payable {
		setValue(initialValue);

		uint256 refund = msg.value / 2;
		(bool success, ) = msg.sender.call{value: refund}("");
		require(success);

		emit Initialized(msg.value, initialValue);
	}

	function setValue(uint256 newValue) public {
		value = newValue;
	}

	function getValue() public view returns (uint256) {
		return value;
	}
}

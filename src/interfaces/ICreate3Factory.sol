// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICreate3Factory {
	function create3(bytes32 salt, bytes memory bytecode) external payable returns (address instance);

	function create3AndInitialize(
		bytes32 salt,
		bytes memory bytecode,
		bytes memory initializer
	) external payable returns (address instance);

	function computeCreate3Address(bytes32 salt) external view returns (address instance);
}

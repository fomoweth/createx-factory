// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICreate2Factory {
	function create2(bytes32 salt, bytes memory bytecode) external payable returns (address instance);

	function create2AndInitialize(
		bytes32 salt,
		bytes memory bytecode,
		bytes memory initializer
	) external payable returns (address instance);

	function computeCreate2Address(bytes32 salt, bytes32 hash) external view returns (address instance);

	function computeCreate2Address(
		bytes32 salt,
		bytes32 hash,
		address deployer
	) external view returns (address instance);
}

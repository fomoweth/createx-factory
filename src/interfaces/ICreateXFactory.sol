// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICreateXFactory {
	function deploy(
		uint256 creationType,
		bytes32 salt,
		bytes memory bytecode
	) external payable returns (address instance);

	function deployAndInitialize(
		uint256 creationType,
		bytes32 salt,
		bytes memory bytecode,
		bytes memory initializer
	) external payable returns (address instance);

	function computeAddress(uint256 creationType, bytes32 salt, bytes32 hash) external view returns (address instance);
}

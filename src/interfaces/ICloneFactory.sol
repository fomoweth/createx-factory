// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICloneFactory {
	function clone(address implementation) external payable returns (address instance);

	function cloneAndInitialize(
		address implementation,
		bytes memory initializer
	) external payable returns (address instance);

	function cloneDeterministic(bytes32 salt, address implementation) external payable returns (address instance);

	function cloneDeterministicAndInitialize(
		bytes32 salt,
		address implementation,
		bytes memory initializer
	) external payable returns (address instance);

	function computeDeterministicAddress(bytes32 salt, address implementation) external view returns (address instance);

	function computeDeterministicAddress(
		bytes32 salt,
		address implementation,
		address deployer
	) external view returns (address instance);
}

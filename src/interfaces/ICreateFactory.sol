// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICreateFactory {
	function create(bytes memory bytecode) external payable returns (address instance);

	function createAndInitialize(
		bytes memory bytecode,
		bytes memory initializer
	) external payable returns (address instance);
}

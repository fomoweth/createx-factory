// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

abstract contract EventsAndErrors {
	event ContractCreation(address indexed instance);
	event ContractCreation2(address indexed instance, bytes32 indexed salt);
	event ContractCreation3(address indexed instance, bytes32 indexed salt);

	event CloneCreation(address indexed instance, address indexed implementation);
	event CloneDeterministicCreation(address indexed instance, address indexed implementation, bytes32 indexed salt);

	event Initialized(uint256 indexed callValue, uint256 indexed initialValue);

	error UnsupportedCreationType(uint256);

	error ProxyCreationFailed();
	error ContractCreationFailed();
	error ContractInitializationFailed();
	error ContractAlreadyExists(address instance);

	error InvalidBytecode();
	error InvalidImplementation();
	error InvalidInitializer();
	error InvalidSalt();
	error RefundFailed();
}

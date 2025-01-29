// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";

import {CreateXFactory} from "src/CreateXFactory.sol";

contract DeployCreateXFactory is Script {
	string internal constant TEST_MNEMONIC = "test test test test test test test test test test test junk";

	address internal broadcaster;

	constructor() {
		configureBroadcaster();
	}

	modifier broadcast() {
		vm.startBroadcast(broadcaster);
		_;
		vm.stopBroadcast();
	}

	function run() external broadcast returns (CreateXFactory createXFactory) {
		Chain memory chain = getChain(block.chainid);

		createXFactory = new CreateXFactory();

		string memory item = "deployment";
		vm.serializeAddress(item, "address", address(createXFactory));
		vm.serializeAddress(item, "deployer", broadcaster);

		string memory obj = "chain";
		vm.serializeUint(obj, "chainId", chain.chainId);
		string memory output = vm.serializeString(obj, "name", chain.chainAlias);

		string memory json = vm.serializeString(item, "chain", output);
		string memory path = string.concat(vm.projectRoot(), "/deployments/", chain.chainAlias, ".json");

		vm.writeJson(json, path);
	}

	function configureBroadcaster() internal {
		uint256 privateKey = vm.envOr({
			name: "PRIVATE_KEY",
			defaultValue: vm.deriveKey({
				mnemonic: vm.envOr({name: "MNEMONIC", defaultValue: TEST_MNEMONIC}),
				index: uint8(vm.envOr({name: "WALLET_INDEX", defaultValue: uint256(0)}))
			})
		});

		broadcaster = vm.rememberKey(privateKey);
	}
}

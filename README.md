# CreateXFactory

CreateXFactory is a smart contract factory that can handle the creation of smart contracts using `CREATE`, `CREATE2`, `CREATE3`, and `MinimalProxy Pattern`.

## Contract Overview

- **CreateFactory** provides functions for handling the smart contract deployments using `CREATE`.

- **Create2Factory** provides functions for handling the smart contract deployments using `CREATE2`.

- **Create3Factory** provides functions for handling the smart contract deployments using `CREATE3`.

- **CloneFactory** provides functions for handling the deployments of `MinimalProxy` contracts.

## Usage

Create `.env` file with the following content:

```text
# EOA
PRIVATE_KEY=YOUR_EOA_PRIVATE_KEY
# Or
MNEMONIC="YOUR_EOA_MNEMONIC"
EOA_INDEX=0 # Optional (default to 0)

# Using Alchemy

ALCHEMY_API_KEY="YOUR_ALCHEMY_API_KEY"

RPC_ETHEREUM="https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}"
RPC_SEPOLIA="https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}"

RPC_OPTIMISM="https://opt-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}"
RPC_OPTIMISM_SEPOLIA="https://opt-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}"

RPC_POLYGON="https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}"
RPC_POLYGON_AMOY="https://polygon-amoy.g.alchemy.com/v2/${ALCHEMY_API_KEY}"

RPC_BASE="https://base-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}"
RPC_BASE_SEPOLIA="https://base-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}"

RPC_ARBITRUM="https://arb-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}"
RPC_ARBITRUM_SEPOLIA="https://arb-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}"

# Using Infura

INFURA_API_KEY="YOUR_INFURA_API_KEY"

RPC_ETHEREUM="https://mainnet.infura.io/v3/${INFURA_API_KEY}"
RPC_SEPOLIA="https://sepolia.infura.io/v3/${INFURA_API_KEY}"

RPC_OPTIMISM="https://optimism-mainnet.infura.io/v3/${INFURA_API_KEY}"
RPC_OPTIMISM_SEPOLIA="https://optimism-sepolia.infura.io/v3/${INFURA_API_KEY}"

RPC_POLYGON="https://polygon-mainnet.infura.io/v3/${INFURA_API_KEY}"
RPC_POLYGON_AMOY="https://polygon-amoy.infura.io/v3/${INFURA_API_KEY}"

RPC_BASE="https://base-mainnet.infura.io/v3/${INFURA_API_KEY}"
RPC_BASE_SEPOLIA="https://base-sepolia.infura.io/v3/${INFURA_API_KEY}"

RPC_ARBITRUM="https://arbitrum-mainnet.infura.io/v3/${INFURA_API_KEY}"
RPC_ARBITRUM_SEPOLIA="https://arbitrum-sepolia.infura.io/v3/${INFURA_API_KEY}"

# Etherscan

ETHERSCAN_API_KEY_ETHEREUM="YOUR_ETHERSCAN_API_KEY"
ETHERSCAN_URL_ETHEREUM="https://api.etherscan.io/api"
ETHERSCAN_URL_SEPOLIA="https://api-sepolia.etherscan.io/api"

ETHERSCAN_API_KEY_OPTIMISM="YOUR_OPTIMISTICSCAN_API_KEY"
ETHERSCAN_URL_OPTIMISM="https://api-optimistic.etherscan.io/api"
ETHERSCAN_URL_OPTIMISM_SEPOLIA="https://api-sepolia-optimistic.etherscan.io/api"

ETHERSCAN_API_KEY_POLYGON="YOUR_POLYGONSCAN_API_KEY"
ETHERSCAN_URL_POLYGON="https://api.polygonscan.com/api"
ETHERSCAN_URL_POLYGON_AMOY="https://api-amoy.polygonscan.com/api"

ETHERSCAN_API_KEY_BASE="YOUR_BASESCAN_API_KEY"
ETHERSCAN_URL_BASE="https://api.basescan.org/api"
ETHERSCAN_URL_BASE_SEPOLIA="https://api-sepolia.basescan.org/api"

ETHERSCAN_API_KEY_ARBITRUM="YOUR_ARBISCAN_API_KEY"
ETHERSCAN_URL_ARBITRUM="https://api.arbiscan.io/api"
ETHERSCAN_URL_ARBITRUM_SEPOLIA="https://api-sepolia.arbiscan.io/api"
```

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Deploy

```shell
# To load the variables in the .env file
source .env

# To deploy and verify our contract
$ forge script script/CreateXFactory.s.sol:DeployCreateXFactory --chain <CHAIN-NAME> --rpc-url <RPC-URL> --broadcast --verify -vvvv
```

## Deployments

| Chain ID | Name             | Address                                                                                                                            |
| -------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 11155111 | Sepolia          | [0x0951FbDcdA628bA2e062917aAE364c324F04ef0A](https://sepolia.etherscan.io/address/0x0951FbDcdA628bA2e062917aAE364c324F04ef0A#code) |
| 421614   | Arbitrum Sepolia | [0x0951FbDcdA628bA2e062917aAE364c324F04ef0A](https://sepolia.arbiscan.io/address/0x0951FbDcdA628bA2e062917aAE364c324F04ef0A#code)  |
| 84532    | Base Sepolia     | [0x0951FbDcdA628bA2e062917aAE364c324F04ef0A](https://sepolia.basescan.org/address/0x0951FbDcdA628bA2e062917aAE364c324F04ef0A#code) |

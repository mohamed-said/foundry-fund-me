## Foundry Fund Me

A toy project to practice solidity and blockchain development using Foundry
framework.

Foundry is a super nice and easy tool built in Rust.

### Foundry Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvv
```

You can also use the included `Makefile` to do deploy. Make sure you include
your RPC URLs and the neccessary keys in your `.env` file.

Example:

```shell
$ make deploy-sepolia
```

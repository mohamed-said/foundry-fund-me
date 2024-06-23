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
Run all the test cases.

```shell
$ forge test
```
To run a specific test:

```shell
$ forge test --mt <test_case_name>
```

To add extra visibility and debug output, you can `-v` | `-vv` | `-vvv`
```shell
$ forge test --mt <test_case_name> -vvv
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots
This command creates a snapshot for the amount of gas used by your functions
and test cases as well.

```shell
$ forge snapshot
```

### Anvil
Use this tool to fire up you local chain for testing and experimentation.

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

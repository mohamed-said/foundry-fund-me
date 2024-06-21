// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local Anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network

    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;
    address constant MAINNET_PRICE_FEED_ADDRESS =
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant SEPOLIA_PRICE_FEED_ADDRESS =
        0x694AA1769357215DE4FAC081bf1f309aDC325306;
    uint256 constant MIANNET_CHAIN_ID = 1;
    uint256 constant SEPOLIA_TEST_CHAIN_ID = 11155111;

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        // ETH/USD price feed address
        // https://docs.chain.link/data-feeds/price-feeds/addresses/?network=ethereum&page=1
        address priceFeed;
    }

    constructor() {
        if (block.chainid == MIANNET_CHAIN_ID) {
            // mainnet chain id
            activeNetworkConfig = getMainnetEthConfig();
            // sepolia test chain id: https://chainlist.org/chain/11155111
        } else if (block.chainid == SEPOLIA_TEST_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthCongig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: MAINNET_PRICE_FEED_ADDRESS
        });

        return mainnetConfig;
    }

    function getSepoliaEthCongig() private pure returns(NetworkConfig memory) {
        // price feed addres
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: SEPOLIA_PRICE_FEED_ADDRESS
        });

        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // this condition is there to aviod creating a new
        // config each time we call the function
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }



}

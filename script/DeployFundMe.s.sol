// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import {PriceConverter} from "./PriceConverter.sol";

contract DeployFundMe is Script {

    function run() external returns (FundMe) {
        // anything before 'startBroadcast'
        // is not going to send a real transaction
        // instead, it's going to run in a simulated environment
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceConfigAddress = helperConfig.activeNetworkConfig();

        // After 'startBroadcast' ,, this starts the real transaction
        // it costs gas
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceConfigAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}

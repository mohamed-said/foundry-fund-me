// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// convention for error handling to use 2 underscores:
// ContractName__ErrorName
error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    // convention for storage variables
    // to be prefixed with s_ (e.g. s_variableName)
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    modifier onlyOwner {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        // storing the length one time prevents the loop
        // from calling the storage N times
        // which saves much more gas per call to storage
        uint256 nFunders = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < nFunders; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    /* Getters */

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunderByIndex(uint256 index) external view returns(address) {
        require(index >= 0 && index < s_funders.length, "Index is out of bound!");
        return s_funders[index];

    }

    function isFunderInListOfFunders(address target) external view returns(bool) {
        require(target != address(0));

        address funder = address(0);
        for (uint256 idx = 0; idx < s_funders.length; idx++) {
            if (s_funders[idx] == target) {
                funder = s_funders[idx];
                break;
            }
        }

        return funder != address(0);
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly

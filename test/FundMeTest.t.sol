// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address private immutable fakeUserAddress = makeAddr("fakeUser");
    uint256 private constant STARTING_BALANCE = 10 ether;

    modifier fundUs() {
        vm.prank(fakeUserAddress);
        fundMe.fund{value: 0.1 ether}();
        _;
    }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(fakeUserAddress, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMessgeSender() public {
        console.log(msg.sender);
        console.log("address(this): %s", address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        console.log("Chain ID: %s", block.chainid);
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithNoEnoughETHProvided() public {
        // expects that the next line fails
        vm.expectRevert();
        // sending 0 ETH, minimum is 5
        fundMe.fund();
    }

    function testFundUpdatesFundDataStructureWhenEnoughETHProvided() public fundUs {
        uint256 amount = fundMe.getAddressToAmountFunded(fakeUserAddress);
        assertEq(amount, 0.1 ether);
    }

    function testAddFunderToFundersStorageByIndex() public fundUs {
        address funder = fundMe.getFunder(0);
        assertEq(funder, fakeUserAddress);
    }

    function testAddFunderToFundersStorageByValue() public fundUs {
        address funder = fundMe.getFunderByAddress(fakeUserAddress);
        assertEq(funder, fakeUserAddress);
    }

    function testGetFunderFailsWithIndexOutOfBound() public fundUs {
        vm.expectRevert();
        fundMe.getFunder(1);
    }

    function testGetFunderFailsWithAddressNotFound() public fundUs {
        vm.expectRevert();
        address irony = msg.sender;
        vm.expectRevert();
        fundMe.getFunderByAddress(irony);
    }

    function testWithdrawFailsWhenNotOwnerTriesToWithdraw() public fundUs {
//        console.log("this: %s", address(this));
//        console.log("owner: %s", fundMe.i_owner());
//        console.log("fake: %s", fakeUserAddress);
        vm.expectRevert();
        vm.prank(fakeUserAddress);
        fundMe.withdraw();
    }
}

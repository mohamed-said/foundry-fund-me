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
    uint256 constant GAS_PRICE = 1;

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

    function test_MinimumDollarIsFive() public {
       assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function test_OwnerIsMessgeSender() public {
        console.log(msg.sender);
        console.log("address(this): %s", address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_PriceFeedVersionIsAccurate() public {
        console.log("Chain ID: %s", block.chainid);
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function test_FundFailsWithNoEnoughETHProvided() public {
        // expects that the next line fails
        vm.expectRevert();
        // sending 0 ETH, minimum is 5
        fundMe.fund();
    }

    function test_FundUpdatesFundDataStructureWhenEnoughETHProvided() public fundUs {
        uint256 amount = fundMe.getAddressToAmountFunded(fakeUserAddress);
        assertEq(amount, 0.1 ether);
    }

    function test_AddFunderToFundersStorageByIndex() public fundUs {
        address funder = fundMe.getFunderByIndex(0);
        assertEq(funder, fakeUserAddress);
    }

    function test_GetFunderFailsWithIndexOutOfBound() public fundUs {
        vm.expectRevert();
        fundMe.getFunderByIndex(1);
    }

    function test_GetFunderReturnsFalseWithAddressNotFound() public fundUs {
        address irony = msg.sender;
        bool result = fundMe.isFunderInListOfFunders(irony);

        vm.expectRevert();
        assert(result);
    }

    function test_GetFunderReturnsTrueWithAddressNotFound() public fundUs {
        assert(fundMe.isFunderInListOfFunders(fakeUserAddress));
    }

    function test_WithdrawFailsWhenNotOwnerTriesToWithdraw() public fundUs {
        vm.expectRevert();
        vm.prank(fakeUserAddress);
        fundMe.withdraw();
    }

    function test_WithdrawWithOneFunder() public {
        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 fundmeBalanceBefore = address(fundMe).balance;

        vm.prank(fundMe.getOwner());


        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 fundmeBalanceAfter = address(fundMe).balance;

        // all the contract balance is withdrawn
        assertEq(fundmeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + fundmeBalanceBefore);
    }

    function test_WithdrawMultipleFunders() public {
        uint160 numberOfFunders = 10;

        // it's not a good practice to be using address(0)
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            hoax(address(i), 0.1 ether);
            fundMe.fund{value: 0.1 ether}();
        }


        uint256 ownerBalanceBefore = fundMe.getOwner().balance;
        uint256 fundmeBalanceBefore = address(fundMe).balance;

        uint256 gasLeftBefore = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasLeftAfter = gasleft();

        uint256 gasUsed = (gasLeftBefore - gasLeftAfter) * tx.gasprice;
        console.log("Gas used: %d", gasUsed);

        uint256 ownerBalanceAfter = fundMe.getOwner().balance;
        uint256 fundmeBalanceAfter = address(fundMe).balance;

        // all the contract balance is withdrawn
        assertEq(fundmeBalanceAfter, 0);
        assertEq(ownerBalanceBefore + fundmeBalanceBefore, ownerBalanceAfter);
    }
}

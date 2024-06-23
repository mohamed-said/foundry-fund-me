// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundInteractions, WithdrawInteractions} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address private immutable fakeUserAddress = makeAddr("fakeUser");
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    uint256 constant SEND_VALUE = 0.1 ether; // 10^17

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(fakeUserAddress, STARTING_BALANCE);
    }

    function test_UserCanFund_Interactions() public {
        FundInteractions fundInteractions = new FundInteractions();
        fundInteractions.fundFundMe(address(fundMe));

        WithdrawInteractions withdrawInteractions = new WithdrawInteractions();
        withdrawInteractions.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }

    function test_UserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(fakeUserAddress).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the fakeUserAddress address
        vm.prank(fakeUserAddress);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawInteractions withdrawFundMe = new WithdrawInteractions();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(fakeUserAddress).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;


        console.log("Owner address: %s", address(fundMe.getOwner()));
        console.log("FundMe address: %s", address(fundMe));

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}

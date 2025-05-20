// SPDX-License-Identifier-MIT

pragma solidity 0.8.19;

import {Raffle} from "src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DeployRaffle} from "script/Deployraffle.s.sol";

contract Raffletest is Test {
    //**public state variables */
    Raffle public raffle;
    HelperConfig public helperconfig;

    uint256 advanceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionid;
    uint32 callbackgaslimit;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperconfig) = deployer.Deploycontract();

        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        advanceFee = config.advanceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionid = config.subscriptionid;
        callbackgaslimit = config.callbackgaslimit;
    }

    function testRaffleStateinitializedasOPEN() public view {
        // test for raffle state should be initialized as OPEN
        assert(raffle.getRafflestate() == Raffle.raffleState.OPEN);
    }
}

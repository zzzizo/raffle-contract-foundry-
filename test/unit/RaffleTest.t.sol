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

    address public PLAYER = address(1);

    //*events//

    event Raffleentered(address indexed player);
    event Winnerpicked(address indexed winner);

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

        vm.deal(PLAYER, 1 ether); // give PLAYER some ETH for testing
    }

    function testRaffleStateinitializedasOPEN() public view {
        // test for raffle state should be initialized as OPEN
        assert(raffle.getRafflestate() == Raffle.raffleState.OPEN);
    }

    function testRafflerevertsWhenYouDontPayEnoughETH() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.raffle__sendmoreeth.selector);
        raffle.enterRaffle{value: 5}();
    }

    function testEmitrafflentered() public {
        // test fucntion need to be fixed
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit Raffleentered(PLAYER);
        raffle.enterRaffle{value: advanceFee}();
    }

    function testDontallowPlayerstoEnterRaffleWhileCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: advanceFee}();
        vm.warp(block.timestamp + interval + 1); // means time has passed
        vm.roll(block.number + 1);
        raffle.performUpKeep("");

        //act
        vm.expectRevert(Raffle.raffle__rafflenotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: advanceFee}();
    }
}

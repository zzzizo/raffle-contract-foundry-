// SPDX-License-Identifier-MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function Deploycontract() public returns (Raffle, HelperConfig) {
        HelperConfig helperconfig = new HelperConfig();
        // local --> deploy mocks, get local config
        // sepolia --> get sepolia config
        HelperConfig.NetworkConfig memory config = helperconfig.getConfig();

        vm.startBroadcast();

        Raffle raffle = new Raffle(
            config.advanceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionid,
            config.callbackgaslimit
        );

        vm.stopBroadcast();

        return (raffle, helperconfig);
    }
}

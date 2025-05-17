// SPDX-License-Identifier-MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {Helperconfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function Deploycontract() public returns (Raffle, Helperconfig) {}
}

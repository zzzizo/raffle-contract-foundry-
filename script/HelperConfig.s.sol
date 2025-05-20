//SPDX-License-Identifier-MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

abstract contract CodeConstants {
    /** mock values declared here */

    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE = 1e9;

    // LINK/ETH
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15;

    uint256 public constant SEPOLIA_ETH_CHAINID = 1115511;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    error Helperconfig_invalidchainid();
    struct NetworkConfig {
        uint256 advanceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionid;
        uint32 callbackgaslimit;
    }
    NetworkConfig public localNetworkconfig;
    mapping(uint256 chainid => NetworkConfig) public networkconfigs; //here mapping named networkconfigs is referring from chainid to Networkconfig declared e.g getsepoliaETHconfig

    constructor() {
        networkconfigs[SEPOLIA_ETH_CHAINID] = getSepoliaETHconfig();
    }

    function getConfigByChainid(
        uint256 chainID
    ) public returns (NetworkConfig memory) {
        if (networkconfigs[chainID].vrfCoordinator != address(0)) {
            return networkconfigs[chainID];
        } else if (chainID == LOCAL_CHAIN_ID) {
            networkconfigs[chainID] = GetorCreateAnvilETHconfig(); // 👈 this line is key
            return networkconfigs[chainID];
        } else {
            revert Helperconfig_invalidchainid();
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainid(block.chainid);
    }

    function getSepoliaETHconfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                advanceFee: 0.01 ether, //1e16;
                interval: 30, // 30 seconds
                vrfCoordinator: 0x3C0Ca683b403E37668AE3DC4FB62F4B29B6f7a3e, //address for sepolia from chainlink vrf
                gasLane: 0x8472ba59cf7134dfe321f4d61a430c4857e8b19cdd5230b09952a92671c24409,
                subscriptionid: 0,
                callbackgaslimit: 500000 //500,000 gas
            });
    }

    function GetorCreateAnvilETHconfig() public returns (NetworkConfig memory) {
        // check to see  if we have any activenetwork config
        if (localNetworkconfig.vrfCoordinator != address(0)) {
            return localNetworkconfig;
        }

        // here would be our mocks deployed

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMOCK = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE,
            MOCK_WEI_PER_UINT_LINK
        );

        vm.stopBroadcast();

        localNetworkconfig = NetworkConfig({
            advanceFee: 0.01 ether, //1e16;
            interval: 30, // 30 seconds
            vrfCoordinator: address(vrfCoordinatorMOCK), //address for sepolia from chainlink vrf
            //doesnt matter
            gasLane: 0x8472ba59cf7134dfe321f4d61a430c4857e8b19cdd5230b09952a92671c24409,
            subscriptionid: 0, // might fix it
            callbackgaslimit: 500000 //500,000 gas
        });

        return localNetworkconfig;
    }
}

//SPDX-License-Identifier-MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

abstract contract CodeConstants{
    uint256 public constant SEPOLIA_ETH_CHAINID = 1115511;
    uint256 public constant ANVIL_CHAINID = 31337 ;

}

contract Helperconfig is CodeConstants,Script {   
    struct NetworkConfig {
        uint256 advanceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionid;
        uint32 callbackgaslimit;
    }
    NetworkConfig public localNetworkconfig;
    mapping(uint256 chainid => NetworkConfig) public networkconfigs;

    constructor(){
        networkconfigs[SEPOLIA_ETH_CHAINID] = getSepoliaETHconfig;
        

    }

    function getSepoliaETHconfig() public pure returns (NetworkConfig) {
        return NetworkConfig({
            advanceFee: 0.01 ether, //1e16;
            interval: 30, // 30 seconds
            vrfCoordinator: 0x3C0Ca683b403E37668AE3DC4FB62F4B29B6f7a3e, //address for sepolia from chainlink vrf 
            gasLane: 0x8472ba59cf7134dfe321f4d61a430c4857e8b19cdd5230b09952a92671c24409, 
            subscriptionid: 0,
            callbackgaslimit: 500000   //500,000 gas          

                
        })
    }
        
    
}

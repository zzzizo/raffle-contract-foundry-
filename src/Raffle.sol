// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Raffle is VRFConsumerBaseV2Plus {
    /** Errors */
    error raffle__sendmoreeth();
    error raffle__transferFailed();
    error raffle__rafflenotOpen();
    error raffle__upKeepNotNeeded(
        uint256 balance,
        uint256 raffleLength,
        uint256 raffleState
    );

    /*type declarations */
    enum raffleState {
        OPEN,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private immutable i_callbackgaslimit;
    uint256 private immutable i_advanceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscription_id;
    uint256 private lasttimestamp;

    address private s_recentWinner;
    raffleState private s_raffleState;

    /*events */

    event Raffleentered(address indexed player);
    event Winnerpicked(address indexed winner);

    address payable[] s_players;

    constructor(
        uint256 advanceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionid,
        uint32 callbackgaslimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_advanceFee = advanceFee;
        i_interval = interval;
        lasttimestamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscription_id = subscriptionid;
        i_callbackgaslimit = callbackgaslimit;
    }

    // CEI , which is actually pattern for function checks, events, interactions
    function enterRaffle() public payable {
        // checks

        if (msg.value < i_advanceFee) {
            revert raffle__sendmoreeth();
        }

        s_players.push(payable(msg.sender));

        if (s_raffleState != raffleState.OPEN) {
            revert raffle__rafflenotOpen();
        }
    }

    /**
     * this is the function for chainlink automation stuff
     * the following should be true in order for upkeepNeeded to be true;
     * 1.the time interval has passed between raffles run
     * 2.the lottery is open
     * 3.the contract has ETH
     * 4.Implicitly, your subscription has LINK
     * @param -ignored
     * @return upkeepNeeded -true if its time to restart the lottery
     * @return -ignored
     */

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool TimehasPassed = ((block.timestamp - lasttimestamp) >= i_interval);
        bool lotteryisOpen = s_raffleState == raffleState.OPEN;
        bool hasbalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;

        return (upkeepNeeded, "");
    }

    function performUpKeep(bytes calldata /*performData */) external {
        // logic for picking a winner
        // checks
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert raffle__upKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

        s_raffleState = raffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscription_id,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackgaslimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });
        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);

        // function requestRandomWords(VRFV2PlusClient.RandomWordsRequest calldata req) external returns (uint256 requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        // checks
        //effects (internal contract size)
        uint256 indexofWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexofWinner];
        s_recentWinner = recentWinner; // we can keep track of the winner by storing it to a storage variable

        s_raffleState = raffleState.OPEN;
        s_players = new address payable[](0); // here we are actually resetting our array to new so that previous players cant have their slot
        lasttimestamp = block.timestamp; // also resetting the time interval
        emit Winnerpicked(s_recentWinner);

        // interactions (external contract interactions)
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert raffle__transferFailed();
        }
    }

    /**getter fucntion  */

    function getRafflestate() external view returns (raffleState) {
        return s_raffleState;
    }
}

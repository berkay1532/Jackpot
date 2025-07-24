// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Jackpot {
    struct Entry {
        address user;
        uint256 amount;
    }

    Entry[] public entries;
    uint256 public totalPool;
    uint256 public lastDrawTime;
    address public owner;
    address public platformAddress;
    // Cadence Arch contract address on Flow EVM
    address cadenceArch = 0x0000000000000000000000010000000000000001;

    constructor(address _platformAddress) {
        owner = msg.sender;
        platformAddress = _platformAddress;
        lastDrawTime = block.timestamp;
    }

    function deposit() external payable {
        require(msg.value > 0, "Must send ETH");

        entries.push(Entry({user: msg.sender, amount: msg.value}));

        totalPool += msg.value;
    }

    function drawWinner() external {
        require(block.timestamp >= lastDrawTime + 1 hours, "Too early");
        require(entries.length > 0, "No entries");

        // revertibleRandom() selector = 0x010c265f
        bytes4 selector = bytes4(keccak256("revertibleRandom()"));

        (bool ok, bytes memory result) = cadenceArch.staticcall(
            abi.encodeWithSelector(selector)
        );

        require(ok && result.length == 32, "VRF call failed");

        uint64 random = abi.decode(result, (uint64));
        uint256 randomWeight = uint256(random) % totalPool;

        // Weighted random selection
        uint256 runningSum = 0;
        address winner;

        for (uint256 i = 0; i < entries.length; i++) {
            runningSum += entries[i].amount;
            if (randomWeight < runningSum) {
                winner = entries[i].user;
                break;
            }
        }

        require(winner != address(0), "No winner selected");

        // Ödül dağılımı
        uint256 platformCut = (totalPool * 5) / 100;
        uint256 prize = totalPool - platformCut;

        payable(platformAddress).transfer(platformCut);
        payable(winner).transfer(prize);

        // Reset for next round
        delete entries;
        totalPool = 0;
        lastDrawTime = block.timestamp;
    }

    function getEntries() external view returns (Entry[] memory) {
        return entries;
    }
}

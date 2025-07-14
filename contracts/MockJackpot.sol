// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockJackpot {
    struct Entry {
        address user;
        uint256 amount;
    }

    Entry[] public entries;
    uint256 public totalPool;
    uint256 public lastDrawTime;
    address public owner;
    address public platformAddress;

    constructor(address _platformAddress) {
        owner = msg.sender;
        platformAddress = _platformAddress;
        lastDrawTime = block.timestamp;
    }

    // Kullanıcı katkısı
    function deposit() external payable {
        require(msg.value > 0, "Must send ETH");

        entries.push(Entry({user: msg.sender, amount: msg.value}));

        totalPool += msg.value;
    }

    // Havuz bilgisi
    function getPool() external view returns (uint256) {
        return totalPool;
    }

    // Kazananı seç ve dağıt
    function drawWinner() external {
        require(block.timestamp >= lastDrawTime + 1 hours, "Too early");
        require(entries.length > 0, "No entries");

        // Weighted random selection
        uint256 randomWeight = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
            )
        ) % totalPool;
        uint256 runningSum = 0;
        address winner;

        for (uint256 i = 0; i < entries.length; i++) {
            runningSum += entries[i].amount;
            if (randomWeight < runningSum) {
                winner = entries[i].user;
                break;
            }
        }

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

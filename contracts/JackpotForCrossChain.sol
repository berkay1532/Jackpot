// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// // LayerZero interfaceden gerekli fonksiyonları ekle
// import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";

// contract Jackpot is NonblockingLzApp {
//     struct Entry {
//         address user;
//         uint256 amount;
//     }

//     Entry[] public entries;
//     uint256 public totalPool;
//     uint256 public lastDrawTime;
//     address public owner;
//     address public platformAddress;

//     // Cadence Arch contract address on Flow EVM
//     address cadenceArch = 0x0000000000000000000000010000000000000001;

//     constructor(
//         address _platformAddress,
//         address _lzEndpoint
//     ) NonblockingLzApp(_lzEndpoint) {
//         owner = msg.sender;
//         platformAddress = _platformAddress;
//         lastDrawTime = block.timestamp;
//     }

//     // Flow EVM üzerindeki kullanıcılar için `deposit` fonksiyonu
//     function deposit() external payable {
//         require(msg.value > 0, "Must send ETH");

//         entries.push(Entry({user: msg.sender, amount: msg.value}));
//         totalPool += msg.value;
//     }

//     // Cross-chain deposit fonksiyonu
//     function depositFromOtherChain(
//         uint16 _srcChainId,
//         bytes calldata _srcAddress,
//         uint256 _amount
//     ) external payable {
//         require(msg.value > 0, "Must send ETH");

//         // Bu fonksiyonla gelen katkıyı entries'e ekleyelim
//         entries.push(Entry({user: msg.sender, amount: _amount}));
//         totalPool += _amount;

//         emit DepositedFromOtherChain(_srcChainId, _srcAddress, _amount);
//     }

//     // LayerZero'dan gelen mesajları alacak fonksiyon
//     function _nonblockingLzReceive(
//         uint16 _srcChainId,
//         bytes memory _srcAddress,
//         uint64 _nonce,
//         bytes memory _payload
//     ) internal override {
//         (address user, uint256 amount) = abi.decode(
//             _payload,
//             (address, uint256)
//         );

//         // Katkı, depositFromOtherChain fonksiyonunda ekleniyor, burada tekrar eklemiyoruz
//         // Gerekirse başka işlemler yapabiliriz, ama katkıyı burada tekrar eklemiyoruz
//     }

//     function drawWinner() external {
//         require(block.timestamp >= lastDrawTime + 1 hours, "Too early");
//         require(entries.length > 0, "No entries");

//         // revertibleRandom() selector = 0x010c265f
//         bytes4 selector = bytes4(keccak256("revertibleRandom()"));

//         (bool ok, bytes memory result) = cadenceArch.staticcall(
//             abi.encodeWithSelector(selector)
//         );

//         require(ok && result.length == 32, "VRF call failed");

//         uint64 random = abi.decode(result, (uint64));
//         uint256 randomWeight = uint256(random) % totalPool;

//         // Weighted random selection
//         uint256 runningSum = 0;
//         address winner;

//         for (uint256 i = 0; i < entries.length; i++) {
//             runningSum += entries[i].amount;
//             if (randomWeight < runningSum) {
//                 winner = entries[i].user;
//                 break;
//             }
//         }

//         require(winner != address(0), "No winner selected");

//         // Ödül dağılımı
//         uint256 platformCut = (totalPool * 5) / 100;
//         uint256 prize = totalPool - platformCut;

//         payable(platformAddress).transfer(platformCut);
//         payable(winner).transfer(prize);

//         // Reset for next round
//         delete entries;
//         totalPool = 0;
//         lastDrawTime = block.timestamp;
//     }

//     function getEntries() external view returns (Entry[] memory) {
//         return entries;
//     }

//     // LayerZero'dan gelen katkıyı alırken bir event tetikleyelim
//     event DepositedFromOtherChain(
//         uint16 indexed _srcChainId,
//         bytes _srcAddress,
//         uint256 _amount
//     );
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VRFTester {
    address cadenceArch = 0x0000000000000000000000010000000000000001;

    function testVRF() external view returns (uint64) {
        bytes4 selector = bytes4(keccak256("revertibleRandom()"));

        (bool ok, bytes memory result) = cadenceArch.staticcall(
            abi.encodeWithSelector(selector)
        );

        require(ok && result.length == 32, "VRF call failed");

        return abi.decode(result, (uint64));
    }

    function testMultipleVRFCalls(
        uint256 count
    ) external view returns (uint64[] memory) {
        uint64[] memory results = new uint64[](count);

        for (uint256 i = 0; i < count; i++) {
            bytes4 selector = bytes4(keccak256("revertibleRandom()"));

            (bool ok, bytes memory result) = cadenceArch.staticcall(
                abi.encodeWithSelector(selector)
            );

            require(ok && result.length == 32, "VRF call failed");
            results[i] = abi.decode(result, (uint64));
        }

        return results;
    }
}

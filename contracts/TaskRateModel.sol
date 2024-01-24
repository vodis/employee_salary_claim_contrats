// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TaskRateModel {
    uint256 public immutable low;
    uint256 public immutable base;
    uint256 public immutable high;

    constructor(uint256 _low, uint256 _base, uint256 _high) {
        low = _low;
        base = _base;
        high = _high;
    }

    function calcTaskRate(
        uint256 amt,
        string memory rate
    ) public view returns (uint256) {
        if (
            keccak256(abi.encodePacked(rate)) ==
            keccak256(abi.encodePacked("low"))
        ) {
            return amt * low;
        } else if (
            keccak256(abi.encodePacked(rate)) ==
            keccak256(abi.encodePacked("base"))
        ) {
            return amt * base;
        } else if (
            keccak256(abi.encodePacked(rate)) ==
            keccak256(abi.encodePacked("high"))
        ) {
            return amt * high;
        } else {
            revert("Invalid rate");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IToken {
    function approve(address spender, uint256 amount) external;

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function balanceOf(address addr) external view returns (uint256);

    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

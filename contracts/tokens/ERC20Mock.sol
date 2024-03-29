// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(uint256 initialSupply) ERC20("MockToken", "USDT") {
        _mint(msg.sender, initialSupply * 10 ** 18);
    }
}

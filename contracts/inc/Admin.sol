// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./IToken.sol";
import "./IUni.sol";

interface IAdmin {
    function AdminAdd(address account) external;

    function AdminDel(address account) external;
}

contract admin is AccessControl {
    // using SafeERC20 for IERC20;
    // Start: Admin functions

    event adminModify(string txt, address addr);
    address[] Admins;

    modifier onlyAdmin() {
        //require(IsAdmin(_msgSender()) || IsAdmin(tx.origin), "Access for Admin only");
        //require(IsAdmin(_msgSender()) || IsAdmin(tx.origin), "Access for Admin only");
        require(
            IsAdmin(_msgSender()) || IsAdmin(tx.origin),
            string.concat(
                "Access for Admin only. Sender: ",
                Strings.toHexString(uint160(_msgSender()), 20),
                " tx.origin: ",
                Strings.toHexString(uint160(tx.origin), 20)
            )
        );
        _;
    }

    function IsAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function AdminAdd(address account) public virtual onlyAdmin {
        require(!IsAdmin(account), "Account already ADMIN");
        grantRole(DEFAULT_ADMIN_ROLE, account);
        emit adminModify("Admin added", account);
        Admins.push(account);
    }

    function AdminDel(address account) public virtual onlyAdmin {
        require(IsAdmin(account), "Account not ADMIN");
        require(_msgSender() != account, "You can`t remove yourself");
        revokeRole(DEFAULT_ADMIN_ROLE, account);
        emit adminModify("Admin deleted", account);
    }

    function AdminList() public view returns (address[] memory) {
        return Admins;
    }

    function AdminGetCoin(uint256 amount) public onlyAdmin {
        if (amount == 0) amount = address(this).balance;
        payable(_msgSender()).transfer(amount);
    }

    function AdminGetToken(
        address tokenAddress,
        uint256 amount
    ) public onlyAdmin {
        if (amount == 0) amount = IToken(tokenAddress).balanceOf(address(this));
        //        IToken(tokenAddress).transferFrom(address(this),_msgSender(), amount);
        IToken(tokenAddress).transfer(_msgSender(), amount * (10 ** IToken(tokenAddress).decimals()));
    }

    function AdminGetNft(
        address tokenAddress,
        uint256 token_id
    ) public onlyAdmin {
        IUni(tokenAddress).safeTransferFrom(
            address(this),
            _msgSender(),
            token_id
        );
    }

    // End: Admin functions
}

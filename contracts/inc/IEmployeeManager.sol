// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IEmployeeManager {
    struct Statuses {
        uint256 id;
        bool isProbationPassed;
        bool isFired;
        bool isBlocked;
        address addr;
    }

    function addEmployee(address, bool) external;

    function fired(address) external;

    function getEmployeeInfo(
        string memory
    ) external view returns (
        Statuses memory
    );
}

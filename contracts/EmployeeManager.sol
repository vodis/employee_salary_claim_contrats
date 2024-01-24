// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./inc/Admin.sol";

contract EmployeeManager is admin {
    event eLog(
        uint256 nn,
        string name,
        string nikname,
        address addr,
        bool isFired,
        uint256 createdAt
    );

    uint256 nn = 0;
    string[] public employeeNicknames;
    uint256 private employeeId;

    struct Statuses {
        uint256 id;
        bool isProbationPassed;
        bool isFired;
        bool isBlocked;
        address addr;
    }

    mapping(string => Statuses) public employee;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function addEmployee(
        string memory nickname,
        address addr,
        bool isProbation
    ) external onlyAdmin returns (bool) {
        require(
            employee[nickname].addr == address(0),
            "Employee with this nickname is exist"
        );
        for (uint256 i = 0; i < employeeId; i++) {
            require(
                employee[employeeNicknames[i]].addr != addr,
                "Employee with this addr is exist"
            );
        }

        employee[nickname].id = ++employeeId;
        employee[nickname].isProbationPassed = isProbation;
        employee[nickname].isProbationPassed = false;
        employee[nickname].isBlocked = false;
        employee[nickname].addr = addr;
        employeeNicknames.push(nickname);

        nn++;
        emit eLog(
            nn,
            "add_employee",
            nickname,
            addr,
            employee[nickname].isFired,
            block.timestamp
        );

        return true;
    }

    function fired(string memory nickname) external onlyAdmin {
        employee[nickname].isFired = true;
        employee[nickname].isBlocked = true;

        nn++;
        emit eLog(
            nn,
            "fired_employee",
            nickname,
            employee[nickname].addr,
            true,
            block.timestamp
        );
    }

    function getEmployeeInfo(
        string memory nickname
    ) external view returns (Statuses memory) {
        return employee[nickname];
    }

    function getAllEmployeeNicknames() external view returns (string[] memory) {
        return employeeNicknames;
    }

    function getEmployeeNicknameByWallet(
        address addr
    ) public view returns (string memory nickname) {
        for (uint256 i = 0; i < employeeId; i++) {
            if (employee[employeeNicknames[i]].addr == addr) {
                return employeeNicknames[i];
            }
        }
        return "";
    }

    function updateEmployeeAddr(string memory nickname, address addr) external onlyAdmin returns (bool) {
        employee[nickname].addr = addr;
        return true;
    }
}

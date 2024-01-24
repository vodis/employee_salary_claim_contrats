// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EmployeeRateModel {
    mapping(address => uint256) internal individualRate;

    function getEmployeeRate(address employee) public view returns (uint256) {
        return individualRate[employee];
    }

    function addEmployeeRate(address employee, uint256 employeeRate) public {
        individualRate[employee] = employeeRate;
    }
}

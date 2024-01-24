// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./inc/IEmployeeManager.sol";
import "./inc/ITaskManager.sol";
import "./inc/Admin.sol";
import "./inc/IToken.sol";

contract ChargeVesting is AccessControl, admin, ReentrancyGuardUpgradeable {
    event eLog(
        uint256 nn,
        string name,
        string nickname,
        uint256 amount,
        uint256 createdAt,
        uint256 taskId,
        uint256 periodId
    );
    event debug(uint256 taskId, uint256[] periodIndexes);

    uint256 nn = 0;
    string public name;

    IToken public usdt;
    ITaskManager public tManager;
    IEmployeeManager public eManager;

    bool private reentrancyGuard;

    constructor(address _usdtAddress, address _tManager, address _eManager) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        usdt = IToken(_usdtAddress);
        tManager = ITaskManager(_tManager);
        eManager = IEmployeeManager(_eManager);
        name = string(abi.encodePacked("ChargeVesting"));
    }

    function updateEManager(address _eManager) public onlyAdmin {
        eManager = IEmployeeManager(_eManager);
    }

    function updateTManager(address _tManager) public onlyAdmin {
        tManager = ITaskManager(_tManager);
    }

    function withdraw() external onlyAdmin {
        uint256 contractBalance = usdt.balanceOf(address(this));
        require(contractBalance > 0, "Contract has no USDT balance");
        require(
            usdt.transfer(_msgSender(), contractBalance),
            "Transfer failed"
        );
    }

    function claimOne(
        uint256 taskId,
        uint256 periodIndex
    ) public nonReentrant returns (uint256) {
        uint256 amount = calculateOne(taskId, periodIndex);

        require(amount > 0, "Invalid amount, nothing to claim to that period");
        require(
            tManager.closeOnePaidPeriod(taskId, periodIndex),
            "Task has already been paid. Claim by same task twice not allow."
        );

        amount = amount * (10 ** IToken(usdt).decimals());

        require(
            usdt.balanceOf(address(this)) >= amount,
            "Balance of claim contract is too small. Contact to support"
        );
        usdt.transfer(msg.sender, amount);
        return amount;
    }

    function calculateOne(
        uint256 taskId,
        uint256 periodIndex
    ) internal returns (uint256 availableToClaim) {
        (
            ,
            ITaskManager.Statuses memory statuses,
            string memory nickname,
            uint256[] memory period,
            uint256[] memory price,
            bool[] memory isAlreadyPaid
        ) = tManager.getTaskInfo(taskId);

        emit debug(taskId, period);

        require(
            statuses.isAlphaStageDone,
            "Task statuses do not allow to claim. Contact to support"
        );
        require(
            !statuses.isTaskStoped,
            "Task is stoped. Contact to support"
        );

        IEmployeeManager.Statuses memory employeeStatuses = eManager.getEmployeeInfo(nickname);

        require(
            !(employeeStatuses.isFired),
            "You are fired. Contact to support"
        );

        require(!isAlreadyPaid[periodIndex], "Period already paid");
        require(period[periodIndex] <= block.timestamp, "Claim is too early");
        return price[periodIndex];
    }

    function claim(string memory nickname) public returns (uint256) {
        uint256 amount = calculate(nickname);

        require(amount > 0, "Invalid amount, nothing to claim to that period");
        require(
            usdt.balanceOf(address(this)) >= amount,
            "Balance of claim contract is too small. Contact to support"
        );

        bool success = false;
        require(!reentrancyGuard, "Reentrancy guard active");
        reentrancyGuard = true;

        try usdt.transfer(msg.sender, amount) returns (bool transferSuccess) {
            success = transferSuccess;
        } catch Error(string memory) {
            // Handle error
        } catch (bytes memory) {
            // Handle error
        }

        reentrancyGuard = false; // Release the guard

        require(success, "Transfer failed");

        nn++;
        emit eLog(nn, "claim", nickname, amount, block.timestamp, 0, 0);

        return amount;
    }

    function calculate(
        string memory nickname
    ) internal returns (uint256 availableToClaim) {
        uint256[] memory taskIds = tManager.getTaskIdsByNickname(nickname);

        uint256[] memory processedTaskIds = new uint256[](taskIds.length);
        uint256 processedTaskCount = 0;

        for (uint256 i = 0; i < taskIds.length; i++) {
            (
                ,
                ITaskManager.Statuses memory statuses,
                ,
                uint256[] memory period,
                uint256[] memory price,
                bool[] memory isAlreadyPaid
            ) = tManager.getTaskInfo(taskIds[i]);

            if (
                !statuses.isAlphaStageDone ||
                statuses.isTaskStoped ||
                statuses.isTaskDone
            ) {
                continue;
            }

            uint256[] memory paidPeriods = new uint256[](period.length);
            uint256 processedPaidPeriodsCount = 0;

            for (uint256 j = 0; j < period.length; j++) {
                if (period[j] <= block.timestamp && !isAlreadyPaid[j]) {
                    availableToClaim += price[j];
                    paidPeriods[processedPaidPeriodsCount] = j;
                    processedPaidPeriodsCount++;

                    processedTaskIds[processedTaskCount] = taskIds[i];
                    processedTaskCount++;

                    nn++;
                    emit eLog(
                        nn,
                        "claim_period",
                        nickname,
                        price[j],
                        block.timestamp,
                        taskIds[i],
                        period[j]
                    );
                }
            }

            require(
                tManager.bundleClosePaidPeriods(taskIds[i], paidPeriods),
                "Task periods were not updated in bundle before paid"
            );
        }

        require(
            tManager.bundleCloseTasks(processedTaskIds),
            "Task state was not been updated in bundle"
        );

        return availableToClaim;
    }
}

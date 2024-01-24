// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./inc/Admin.sol";

contract TaskManager is admin {
    event eLog(
        uint256 nn,
        string name,
        uint256 taskId,
        string nickname,
        uint256[] periods,
        uint256[] prices,
        bool[] isAlreadyPaid,
        uint256 createdAt,
        string title
    );
    event debug(uint256 taskId, uint256 taskPeriodCountById);

    uint256 nn = 0;
    uint256 private taskId;

    struct Statuses {
        bool isTaskOpened;
        bool isTaskStoped;
        bool isTaskDone;
        bool isAlphaStageDone;
    }

    struct Meta {
        uint256 id;
        string title;
        string description;
    }

    struct TaskStages {
        Meta meta;
        Statuses taskStatus;
        string nickname;
        mapping(uint256 => uint256) period;
        mapping(uint256 => uint256) price;
        mapping(uint256 => bool) isAlreadyPaid;
    }

    mapping(uint256 => TaskStages) internal tasks;
    mapping(uint256 => uint256) public taskPeriodCount;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function addTask(
        string memory title,
        string memory description,
        string memory nickname,
        uint256[] memory periods,
        uint256[] memory prices
    ) external onlyAdmin returns (uint256) {
        require(periods.length == prices.length, "period doesn't have payment");
        uint256 id = taskId++;
        _add(id, title, description, nickname, periods, prices);

        return id;
    }

    function _add(
        uint256 id,
        string memory title,
        string memory description,
        string memory nickname,
        uint256[] memory periods,
        uint256[] memory prices
    ) internal {
        tasks[id].meta.id = id;
        tasks[id].meta.title = title;
        tasks[id].meta.description = description;
        tasks[id].taskStatus.isTaskOpened = true;
        tasks[id].taskStatus.isTaskStoped = false;
        tasks[id].taskStatus.isTaskDone = false;
        tasks[id].taskStatus.isAlphaStageDone = false;
        tasks[id].nickname = nickname;

        for (uint256 i = 0; i < periods.length; i++) {
            tasks[id].period[i] = periods[i];
            tasks[id].price[i] = prices[i];
            tasks[id].isAlreadyPaid[i] = false;
        }

        taskPeriodCount[id] = periods.length;

        nn++;
        emit eLog(
            nn,
            "add_task",
            id,
            nickname,
            periods,
            prices,
            getIsAlreadyPaid(id),
            block.timestamp,
            title
        );
    }

    function calculateActiveTasks() external view returns (uint256) {
        uint256 activeTaskCount = 0;

        for (uint256 id = 0; id < taskId; id++) {
            if (tasks[id].taskStatus.isTaskOpened) {
                activeTaskCount++;
            }
        }

        return activeTaskCount;
    }

    function getTaskInfo(
        uint256 id
    )
        external
        view
        returns (
            Meta memory,
            Statuses memory,
            string memory,
            uint256[] memory,
            uint256[] memory,
            bool[] memory
        )
    {
        return (
            tasks[id].meta,
            tasks[id].taskStatus,
            tasks[id].nickname,
            getPeriods(id),
            getPrices(id),
            getIsAlreadyPaid(id)
        );
    }

    function getTaskIdsByNickname(
        string memory nickname
    ) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](taskId);

        uint256 count = 0;
        for (uint256 i = 0; i < taskId; i++) {
            if (
                keccak256(bytes(tasks[i].nickname)) ==
                keccak256(bytes(nickname))
            ) {
                result[count] = i;
                count++;
            }
        }

        // Resize the result array to remove unused elements
        uint256[] memory finalResult = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            finalResult[i] = result[i];
        }

        return finalResult;
    }

    function getPeriods(uint256 id) internal view returns (uint256[] memory) {
        uint256[] memory periods = new uint256[](getTaskPeriodCount(id));

        for (uint256 i = 0; i < periods.length; i++) {
            periods[i] = tasks[id].period[i];
        }
        return periods;
    }

    function getPrices(uint256 id) internal view returns (uint256[] memory) {
        uint256[] memory prices = new uint256[](getTaskPeriodCount(id));

        for (uint256 i = 0; i < prices.length; i++) {
            prices[i] = tasks[id].price[i];
        }
        return prices;
    }

    function getIsAlreadyPaid(
        uint256 id
    ) internal view returns (bool[] memory) {
        bool[] memory alreadyPaid = new bool[](getTaskPeriodCount(id));

        for (uint256 i = 0; i < alreadyPaid.length; i++) {
            alreadyPaid[i] = tasks[id].isAlreadyPaid[i];
        }
        return alreadyPaid;
    }

    function getTaskPeriodCount(uint256 id) internal view returns (uint256) {
        return taskPeriodCount[id];
    }

    function approveTaskById(uint256 id) external onlyAdmin returns (bool) {
        tasks[id].taskStatus.isAlphaStageDone = true;
        return true;
    }

    function stopTaskById(uint256 id) external onlyAdmin returns (bool) {
        require(tasks[id].taskStatus.isTaskDone != true, "Task already done");
        tasks[id].taskStatus.isTaskStoped = true;
        return true;
    }

    function openTaskById(uint256 id) external onlyAdmin returns (bool) {
        require(tasks[id].taskStatus.isTaskDone != true, "Task already done");
        tasks[id].taskStatus.isTaskStoped = false;
        return true;
    }

    function closePaidPeriod(
        uint256 id,
        uint256 paidPeriodId
    ) external onlyAdmin returns (bool) {
        emit debug(id, taskPeriodCount[id]);
        require(paidPeriodId <= taskPeriodCount[id], "Invalid period id");
        require(
            tasks[id].isAlreadyPaid[paidPeriodId],
            "Task period already paid"
        );
        tasks[id].isAlreadyPaid[paidPeriodId] = true;

        nn++;
        emit eLog(
            nn,
            "paid_period",
            id,
            tasks[id].nickname,
            getPeriods(id),
            getPrices(id),
            getIsAlreadyPaid(id),
            block.timestamp,
            tasks[id].meta.title
        );
        return true;
    }

    function closeOnePaidPeriod(
        uint256 id,
        uint256 paidPeriodId
    ) external onlyAdmin returns (bool) {
        emit debug(id, taskPeriodCount[id]);
        if (tasks[id].isAlreadyPaid[paidPeriodId]) {
            return false;
        }
        tasks[id].isAlreadyPaid[paidPeriodId] = true;

        nn++;
        emit eLog(
            nn,
            "paid_one",
            id,
            tasks[id].nickname,
            getPeriods(id),
            getPrices(id),
            getIsAlreadyPaid(id),
            block.timestamp,
            tasks[id].meta.title
        );

        return true;
    }

    function bundleClosePaidPeriods(
        uint256 id,
        uint256[] memory paidPeriodIds
    ) external onlyAdmin returns (bool) {
        emit debug(id, paidPeriodIds[id]);
        uint256[] memory paidPricesAmounts = new uint256[](0);
        for (uint256 i = 0; i < paidPeriodIds.length; i++) {
            require(
                paidPeriodIds[i] <= taskPeriodCount[id],
                "Invalid period id"
            );

            tasks[id].isAlreadyPaid[paidPeriodIds[i]] = true;
            paidPricesAmounts[i] = tasks[id].price[i];
        }

        nn++;
        emit eLog(
            nn,
            "paid_bundle",
            id,
            tasks[id].nickname,
            paidPeriodIds,
            paidPricesAmounts,
            getIsAlreadyPaid(id),
            block.timestamp,
            tasks[id].meta.title
        );
        return true;
    }

    function bundleCloseTasks(
        uint256[] memory ids
    ) external onlyAdmin returns (bool) {
        for (uint256 i = 0; i < ids.length; i++) {
            if (allPeriodsAlreadyPaid(ids[i])) {
                tasks[ids[i]].taskStatus.isTaskOpened = false;
                tasks[ids[i]].taskStatus.isTaskDone = true;
            }
        }

        return true;
    }

    function allPeriodsAlreadyPaid(uint256 id) internal returns (bool) {
        uint256[] memory paidPeriods = new uint256[](0);
        uint256[] memory paidPrices = new uint256[](0);
        for (uint256 j = 1; j < taskPeriodCount[id]; j++) {
            if (!tasks[id].isAlreadyPaid[j]) {
                return false;
            }
            paidPeriods[j] = tasks[id].period[j];
            paidPrices[j] = tasks[id].price[j];
        }

        nn++;
        emit eLog(
            nn,
            "task_done",
            id,
            tasks[id].nickname,
            paidPeriods,
            paidPrices,
            getIsAlreadyPaid(id),
            block.timestamp,
            tasks[id].meta.title
        );

        return true;
    }
}

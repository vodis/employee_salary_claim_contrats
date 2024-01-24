// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITaskManager {
    struct Meta {
        uint256 id;
        string title;
        string description;
    }

    struct Statuses {
        bool isTaskOpened;
        bool isTaskStoped;
        bool isTaskDone;
        bool isAlphaStageDone;
    }

    function getTaskInfo(
        uint256
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
        );

    function calculateActiveTasks() external view returns (uint256);

    function getTaskIdsByNickname(
        string memory nickname
    ) external view returns (uint256[] memory);

    function bundleCloseTasks(uint256[] memory ids) external returns (bool);

    function closeOnePaidPeriod(
        uint256 id,
        uint256 paidPeriodId
    ) external returns (bool);

    function bundleClosePaidPeriods(
        uint256 id,
        uint256[] memory paidPeriodIds
    ) external returns (bool);
}

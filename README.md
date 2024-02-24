[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Intro to Solidity Employee Salary Claim contracts

Welcome to the Employee Salary Claim contracts repository. The main aim of the application is to allow the employer (administrator) to create tasks for employees with deadlines and stage periods. Stage period, which must be approved by employer is kind of a gateway which opens for employees ability to claim their funds for specific period, and then repeatedly claim remain on specified period till all payment will be issued.

# Linked

Repository for application, which works in conjunction with the contracts - [here](https://github.com/vodis/employee_salary_claim_app)

## Available Main Scripts

In the project directory, you can run:

### `npm run local-network:run`

Runs local Ethereum network node.<br>
Read article [Hardhat Network](https://hardhat.org/hardhat-network/docs/overview) to get more details.

### `npm run local-network:deploy`

Compiles and deployed contracts described in `deployAll` script.

`npm install`

### Fork Network, ChainId 31337

supperAdmin 0x2780321eB3C1306a659F965a9901435861dd9Ff9
Erc20Mock 0x8Df2e40e2374e119372b76362F074365C743C86C

EmployeeManager 0x8AFE0ecCd5F4fF6d9cf02eECCEF6b2e4C4F44c75
EmployeeRateModel 0xcABDa4B159649E6bAa56F711c0Fb84ADEcbD1575

TaskManager 0x9a2d01D2E297ff9824Ca7fF00E141561443D05d9
TaskRateModel 0xdfBebb5671cf165e93251e926c97022bB7Aa97Ba

ChargeVesting 0x61A3Ae286188e82d6E27567348F6a23f21939D9D

### Localhost Network

supperAdmin 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Erc20Mock 0x31403b1e52051883f2Ce1B1b4C89f36034e1221D

EmployeeManager 0x4278C5d322aB92F1D876Dd7Bd9b44d1748b88af2
EmployeeRateModel 0x0D92d35D311E54aB8EEA0394d7E773Fc5144491a

TaskManager 0x24EcC5E6EaA700368B8FAC259d3fBD045f695A08
TaskRateModel 0x876939152C56362e17D508B9DEA77a3fDF9e4083

ChargeVesting 0xD56e6F296352B03C3c3386543185E9B8c2e5Fd0b

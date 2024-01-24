const hre = require("hardhat");
const fs = require("fs");

const ethers = hre.ethers;

// Team
const { ASSIGN_ADMIN_TO_ADDR } = process.env;

async function deployAll() {
  const [supperAdmin] = await ethers.getSigners();
  const chainId = await supperAdmin.getChainId();
  console.log("Deploying - ChainId", chainId);
  console.log("Deployer - SupperAdmin", supperAdmin.address);

  // Deploying
  const erc20Mock = await hre.ethers.getContractFactory("ERC20Mock");
  const Erc20Mock = await erc20Mock.deploy(1000000);
  await Erc20Mock.deployed();
  console.log("Erc20Mock", Erc20Mock.address);

  const employeeManager = await hre.ethers.getContractFactory("EmployeeManager");
  const EmployeeManager = await employeeManager.deploy();
  await EmployeeManager.deployed();
  console.log("EmployeeManager", EmployeeManager.address);

  const employeeRateModel = await hre.ethers.getContractFactory("EmployeeRateModel");
  const EmployeeRateModel = await employeeRateModel.deploy();
  await EmployeeRateModel.deployed();
  console.log("EmployeeRateModel", EmployeeRateModel.address);

  const taskManager = await hre.ethers.getContractFactory("TaskManager");
  const TaskManager = await taskManager.deploy();
  await TaskManager.deployed();
  console.log("TaskManager", TaskManager.address);

  const taskRateModel = await hre.ethers.getContractFactory("TaskRateModel");
  const COF_1 = 1;
  const COF_2 = 2;
  const COF_3 = 3;
  const TaskRateModel = await taskRateModel.deploy(COF_1, COF_2, COF_3);
  await TaskRateModel.deployed();
  console.log("TaskRateModel", TaskRateModel.address);

  const chargeVesting = await hre.ethers.getContractFactory("ChargeVesting");
  const ChargeVesting = await chargeVesting.deploy(Erc20Mock.address, TaskManager.address, EmployeeManager.address);
  await ChargeVesting.deployed();
  console.log("ChargeVesting", ChargeVesting.address);

  // Add Admin addresses
  if (ASSIGN_ADMIN_TO_ADDR) {
    const taskManagerContract = await hre.ethers.getContractAt(
      "TaskManager",
      TaskManager.address
    );
    await taskManagerContract.AdminAdd(ChargeVesting.address);
    await taskManagerContract.AdminAdd(ASSIGN_ADMIN_TO_ADDR);
  
    const employeeManagerContract = await hre.ethers.getContractAt(
      "EmployeeManager",
      EmployeeManager.address
    );
    await employeeManagerContract.AdminAdd(ChargeVesting.address);
    await employeeManagerContract.AdminAdd(ASSIGN_ADMIN_TO_ADDR);
  
    const chargeVestingContract = await hre.ethers.getContractAt(
      "ChargeVesting",
      ChargeVesting.address
    );
    await chargeVestingContract.AdminAdd(ASSIGN_ADMIN_TO_ADDR);
  }
}

deployAll().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
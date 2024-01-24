/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-web3');
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
const dotenv = require("dotenv");

dotenv.config();

const { INFURA_API_KEY, DEPLOYER_PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.19",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
        // blockNumber: 18888888,
      },
      accounts: {
        count: 10,
      },
    },
    fork: {
      url: 'https://rpc-fork.airdrop-hunter.site',
       accounts: [DEPLOYER_PRIVATE_KEY],
    },
  },
};
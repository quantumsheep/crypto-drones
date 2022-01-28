import * as dotenv from "dotenv";

import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-web3";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import { HardhatUserConfig, task } from "hardhat/config";
import "solidity-coverage";

dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("drones-mint", "Mint a drone")
  .addParam("account", "The account's address")
  .addParam("address", "The contract's address")
  .setAction(async (taskArgs, hre) => {
    const { account, address } = taskArgs;

    const Contract = await hre.ethers.getContractFactory("CryptoDrones");
    const contract = Contract.attach(address);

    const droneId = await contract.mintOwner(account);
    console.log(droneId);
  });

task("drones-list", "Prints the list of drones")
  .addParam("account", "The account's address")
  .addParam("address", "The contract's address")
  .setAction(async (taskArgs, hre) => {
    const { account, address } = taskArgs;

    const Contract = await hre.ethers.getContractFactory("CryptoDrones");
    const contract = Contract.attach(address);

    const balance = await contract.balanceOf(account);
    console.log("Account balance:", balance.toString());

    for (let i = 0; i < balance; i++) {
      const droneID = await contract.tokenOfOwnerByIndex(account, i);
      const drone = await contract.getDrone(droneID);
      console.log(drone);
    }
  });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;

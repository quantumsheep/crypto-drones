import { ethers } from "hardhat";

async function main() {
  const [wallet] = await ethers.getSigners();

  console.log("Running contract with the account:", wallet.address);

  const Contract = await ethers.getContractFactory("CryptoDrones");
  const contract = Contract.attach("<deployed address>");

  const balance = await contract.balanceOf(wallet.address);
  console.log("Account balance:", balance.toString());

  for (let i = 0; i < balance; i++) {
    const droneID = await contract.tokenOfOwnerByIndex(wallet.address, i);
    const drone = await contract.getDrone(droneID);
    console.log(drone);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { expect } from "chai";
import { ethers } from "hardhat";

describe("CryptoDrones", function () {
  it("Should create a new drone", async function () {
    const CryptoDrones = await ethers.getContractFactory("CryptoDrones");
    const instance = await CryptoDrones.deploy();
    await instance.deployed();

    const baseSupply = await instance.totalSupply();

    const mintTx = await instance.mint();
    await mintTx.wait();

    const newSupply = await instance.totalSupply();

    expect(baseSupply.toNumber() + 1).to.equal(newSupply.toNumber());
  });
});

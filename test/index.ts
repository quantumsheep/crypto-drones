import { expect } from "chai";
import { ethers } from "hardhat";

describe("CryptoDrones", function () {
  it("Should mint a new drone", async function () {
    const CryptoDrones = await ethers.getContractFactory("CryptoDrones");
    const instance = await CryptoDrones.deploy();
    await instance.deployed();

    const [wallet] = await ethers.getSigners();

    expect(await instance.totalSupply()).to.equal(0);

    await expect(instance.mint())
      .to.emit(instance, "Transfer")
      .withArgs(
        "0x0000000000000000000000000000000000000000",
        wallet.address,
        0
      );

    expect(await instance.totalSupply()).to.equal(1);
  });

  it("Should prevent mint of multiple drones", async function () {
    const CryptoDrones = await ethers.getContractFactory("CryptoDrones");
    const instance = await CryptoDrones.deploy();
    await instance.deployed();

    const mintTx = await instance.mint();
    await mintTx.wait();

    await expect(instance.mint()).to.be.revertedWith(
      "You already have a drone"
    );
  });

  it("Should burn a drone", async function () {
    const CryptoDrones = await ethers.getContractFactory("CryptoDrones");
    const instance = await CryptoDrones.deploy();
    await instance.deployed();

    const [wallet] = await ethers.getSigners();

    const mintTx = await instance.mint();
    await mintTx.wait();

    await expect(instance.burn(0))
      .to.emit(instance, "Transfer")
      .withArgs(
        wallet.address,
        "0x0000000000000000000000000000000000000000",
        0
      );
  });
});

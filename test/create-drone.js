const truffleAssert = require('truffle-assertions');

const CryptoDrones = artifacts.require('CryptoDrones');

const waitForEvent = (result, eventType) => new Promise((resolve) => {
  truffleAssert.eventEmitted(result, eventType, resolve);
});

contract("CryptoDrones", (accounts) => {
  it("should create a new drone", async () => {
    const instance = await CryptoDrones.deployed();

    const baseSupply = await instance.totalSupply();

    await waitForEvent(
      await instance.createDrone(),
      'Transfer',
    );

    const currentSupply = await instance.totalSupply();
    expect(baseSupply.toNumber() + 1).to.equal(currentSupply.toNumber());
  });
});

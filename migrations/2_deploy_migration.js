const CryptoDrones = artifacts.require("CryptoDrones");

module.exports = async function (deployer) {
  await deployer.deploy(CryptoDrones);
};

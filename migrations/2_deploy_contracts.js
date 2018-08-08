var Courier = artifacts.require("Courier");

module.exports = function(deployer) {
  deployer.deploy(Courier, "SHIPMENT001", "0xa41d7DDbb4013442529D9Ab5351Bc372612BeAb1");
};

const RoamCoin = artifacts.require("RoamCoin");
const RoamProxy = artifacts.require("RoamProxy");

module.exports = async function(deployer, network, accounts) {
  const ownerAddress = accounts[0]; // Use the first account as the owner

  // Step 1: Deploy the RoamCoin logic contract (do NOT call initialize yet)
  await deployer.deploy(RoamCoin);
  const roamCoin = await RoamCoin.deployed();

  // Step 2: Deploy the RoamProxy contract with the address of the RoamCoin implementation
  await deployer.deploy(RoamProxy, roamCoin.address);
  const proxy = await RoamProxy.deployed();

  // Step 3: Initialize RoamCoin via the proxy (call initialize on the proxy, not the implementation)
  const proxiedRoamCoin = await RoamCoin.at(proxy.address);

  // Initialize the RoamCoin contract through the proxy
  await proxiedRoamCoin.initialize(ownerAddress);

  console.log("Deployment complete:");
  console.log("RoamCoin logic address:", roamCoin.address);
  console.log("Proxy contract address:", proxy.address);
  console.log("Owner address:", ownerAddress);
};

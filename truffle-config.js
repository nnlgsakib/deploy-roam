const HDWalletProvider = require('@truffle/hdwallet-provider');
const {mainnet_rpc} = require('msc-js');
const MNEMONIC = "";
const privatkey =   ['']
const PROJECT_ID = "ab2d4fbcfbc14fdc990905bb7e2cb097";
const ETHERSCAN = "MJE46ZWVV3GJ21UUTG2P1C7BG3K1YNFJFP"; 
const BSC = "QPBKJJ3A5IHHNFGHHVF68AVY3T7M89JNUN";
module.exports = {

plugins: [
 'truffle-plugin-verify'
],
api_keys: {
 etherscan: ETHERSCAN
},
api_keys: {
 bscscan: BSC
},
networks: {
 goerli: {
   provider: () => new HDWalletProvider(MNEMONIC, `https://goerli.infura.io/v3/${PROJECT_ID}`),
    network_id: 5,       // Goerli's id
    confirmations: 2,    // # of confirmations to wait between deployments. (default: 0)
    timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
   skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
 },
 testnet: {
   provider: () => new HDWalletProvider(MNEMONIC, `https://data-seed-prebsc-1-s1.binance.org:8545`),
   network_id: 97,
   confirmations: 10,
   timeoutBlocks: 200,
   skipDryRun: true
 },
 bsc: {
   provider: () => new HDWalletProvider(privatkey, `https://bsc-dataseed1.binance.org`),
   network_id: 56,
   confirmations: 10,
   timeoutBlocks: 200,
   skipDryRun: true
 },
 msc: {
 provider : () => new HDWalletProvider(privatkey, mainnet_rpc.http),
  network_id: 9996,
  confirmations: 1,
  timeoutBlocks: 200,
  skipDryRun: true
},
 //
 // Useful for private networks
  private: {
    provider: () => new HDWalletProvider(MNEMONIC, mainnet_rpc.http),
    network_id: 4,   // This network is yours, in the cloud.
    production: true    // Treats this network as if it was a public net. (default: false)
  }
},

// Set default mocha options here, use special reporters, etc.
mocha: {
 // timeout: 100000
},

// Configure your compilers
compilers: {
 solc: {
   version: "0.8.25" ,// Fetch exact version from solc-bin (default: truffle's version)
   // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
   settings: {          // See the solidity docs for advice about optimization and evmVersion
    optimizer: {
      enabled: true,
      runs: 200
    },
    evmVersion: "paris"
   }
 }
}
};
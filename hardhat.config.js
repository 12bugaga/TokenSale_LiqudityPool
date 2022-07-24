require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

module.exports = {
  solidity: "0.8.15",
  networks: {
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/ff46321f80814e7c80a1e4daf4714591",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

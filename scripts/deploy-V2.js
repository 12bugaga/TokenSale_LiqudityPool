const { ethers, upgrades } = require("hardhat");

const PROXY = "";

async function main() {
    const BugagaTokenV2 = await ethers.getContractFactory("BugagaTokenV2");
    console.log("Upgrading BugagaToken...");
    await upgrades.upgradeProxy(PROXY, BugagaTokenV2);
    console.log("BugagaToken upgraded");
}

main();
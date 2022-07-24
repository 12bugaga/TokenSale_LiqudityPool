const { ethers, upgrades } = require("hardhat");

async function main() {
    const BugagaToken = await ethers.getContractFactory("BugagaToken");
    console.log("Deploying BugagaToken...");
    const box = await upgrades.deployProxy(BugagaToken, {
        initializer: "initialize",
    });
    await box.deployed();
    console.log("BugagaToken deployed to:", box.address);
}

main();
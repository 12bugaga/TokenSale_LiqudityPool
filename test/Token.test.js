const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

describe("Token bugaga init", () => {
    let owner;
    let token;

    before(async() => {
        [owner] = await ethers.getSigners();

        const Token = await ethers.getContractFactory("BugagaToken");
        token = await Token.deploy();
        await token.deployed();
    })

    it("Get half of total supply to msg.sender when created", async() => {
        expect((await token.balanceOf(owner.address)) / 10**18).to.equal(5000);
    });
})
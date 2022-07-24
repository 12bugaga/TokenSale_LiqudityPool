const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

const toWei = (value) => ethers.utils.parseEther(value.toString());

const fromWei = (value) =>
  ethers.utils.formatEther(
    typeof value === "string" ? value : value.toString()
  );

const getBalance = ethers.provider.getBalance;

describe("Exchange", () => {
    let owner;
    let token;
    let exchange;

    beforeEach(async() => {
        [owner, user] = await ethers.getSigners();
        const Token = await ethers.getContractFactory("BugagaToken");
        token = await Token.deploy();
        await token.deployed();

        const Exchange = await ethers.getContractFactory("Exchange");
        exchange = await Exchange.deploy(token.address);
        await exchange.deployed();
    })

    it("Adds liquidity", async () => {
        await token.approve(exchange.address, toWei(200));
        await exchange.addLiquidity(toWei(200), { value: toWei(100) });

        expect(await getBalance(exchange.address)).to.equal(toWei(100));
        expect(await exchange.getReserve()).to.equal(toWei(200));
    });

    it("Returns correct token amount or otherwise - the price", async () => {
        await token.approve(exchange.address, toWei(2000));
        await exchange.addLiquidity(toWei(2000), { value: toWei(1000) });
  
        let tokensOut = await exchange.getTokenAmount(toWei(1));
        expect(fromWei(tokensOut)).to.equal("1.998001998001998001");
  
        tokensOut = await exchange.getTokenAmount(toWei(100));
        expect(fromWei(tokensOut)).to.equal("181.818181818181818181");
  
        tokensOut = await exchange.getTokenAmount(toWei(1000));
        expect(fromWei(tokensOut)).to.equal("1000.0");
    });
})
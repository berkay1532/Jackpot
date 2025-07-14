import { ethers } from "hardhat";
import { expect } from "chai";
import { Jackpot } from "../typechain-types";

describe("Jackpot Contract", () => {
  let jackpot: Jackpot;
  let owner: any, platform: any, user1: any, user2: any;

  beforeEach(async () => {
    [owner, platform, user1, user2] = await ethers.getSigners();
    const JackpotFactory = await ethers.getContractFactory("Jackpot");
    jackpot = (await JackpotFactory.deploy(platform.address)) as Jackpot;
    // waitForDeployment() kullanın deployed() yerine (Hardhat v2+ için)
    await jackpot.waitForDeployment();
  });

  it("should accept deposits and track total pool", async () => {
    await jackpot.connect(user1).deposit({ value: ethers.parseEther("1") });
    await jackpot.connect(user2).deposit({ value: ethers.parseEther("2") });

    // getAddress() kullanın address yerine (ethers v6+ için)
    const balance = await ethers.provider.getBalance(await jackpot.getAddress());
    expect(balance).to.equal(ethers.parseEther("3"));
  });

  it("should revert drawWinner if called before 1 hour", async () => {
    await jackpot.connect(user1).deposit({ value: ethers.parseEther("1") });

    await expect(jackpot.drawWinner()).to.be.revertedWith("Too early")
  });

  it("should select a winner and distribute funds correctly", async () => {
    await jackpot.connect(user1).deposit({ value: ethers.parseEther("1") });
    await jackpot.connect(user2).deposit({ value: ethers.parseEther("3") });

    // Simulate 1 hour passing
    await ethers.provider.send("evm_increaseTime", [3600]);
    await ethers.provider.send("evm_mine", []);

    const platformBalanceBefore = await ethers.provider.getBalance(platform.address);
    await jackpot.drawWinner();
    const platformBalanceAfter = await ethers.provider.getBalance(platform.address);
    
    const expectedCut = ethers.parseEther("0.2"); // 5% of 4

    expect(platformBalanceAfter - platformBalanceBefore).to.equal(expectedCut);
    
    const finalPoolBalance = await ethers.provider.getBalance(await jackpot.getAddress());
    expect(finalPoolBalance).to.equal(0);
  });
});
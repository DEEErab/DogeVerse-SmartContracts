// bored-ape.test.ts
import { expect } from "chai";
import { ethers } from "hardhat";
import { beforeEach } from "mocha";
import { Contract } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("DogeVerse", () => {
  let dogeVerse: Contract;
  let owner: SignerWithAddress;
  let address1: SignerWithAddress;

  beforeEach(async () => {
    const dogeVerseFactory = await ethers.getContractFactory("DogeVerse");
    [owner, address1] = await ethers.getSigners();
    dogeVerse = await dogeVerseFactory.deploy(
      "DogeVerse",
      "DG",
      "TEST",
      "Test"
    );
  });

  it("Should initialize the DogeVerse contract", async () => {
    expect(await dogeVerse.maxSupply()).to.equal("8888");
  });

  it("Should set the right owner", async () => {
    expect(await dogeVerse.owner()).to.equal(owner.address);
  });

  it("Check to see if contract is paused 'true'", async () => {
    expect(await dogeVerse.paused()).to.be.true;
  });

  it("Check to see if contract is un-paused 'false'", async () => {
    await dogeVerse.pause(false);
    expect(await dogeVerse.paused()).to.be.false;
  });

  it("Check the mint price '0.069 Ether'", async () => {
    expect(await dogeVerse.cost()).to.equal("69000000000000000");
  });

  it("Check the maxSupply '8888'", async () => {
    expect(await dogeVerse.maxSupply()).to.equal("8888");
  });

  it("Check the maxMintAmount '15'", async () => {
    expect(await dogeVerse.maxMintAmount()).to.equal("15");
  });

  it("Check the freeMintLimit '800'", async () => {
    expect(await dogeVerse.freeMintLimit()).to.equal("800");
  });

  it("Check the free limitPerWallet '1'", async () => {
    expect(await dogeVerse.limitPerWallet()).to.equal("1");
  });

  it("Check pre-reveal 'false'", async () => {
    expect(await dogeVerse.revealed()).to.be.false;
  });

  it("Check meta-data reveal 'true'", async () => {
    await dogeVerse.reveal();
    expect(await dogeVerse.revealed()).to.be.true;
  });

  it("Should mint an NFT for free", async () => {
    await dogeVerse.pause(false);
    expect(
      await dogeVerse.mint(1, {
        value: ethers.utils.parseEther("0.00"),
      })
    )
      .to.emit(dogeVerse, "Transfer")
      .withArgs(ethers.constants.AddressZero, owner.address, "1");
  });

  it("Should fail to mint an NFT for free", async () => {
    await dogeVerse.pause(false);
    expect(
      // should fail by trying to mint more than one
      dogeVerse.mint(2, {
        value: ethers.utils.parseEther("0.00"),
      })
    ).to.be.reverted;
  });
});

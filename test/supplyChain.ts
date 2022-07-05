import { ethers } from "hardhat";
import { expect } from "chai";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";

import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("SupplyChain", function () {
  
  const productName = "Product 1";
  const productDescription = "Description of Product 1";

  async function deployOneYearLockFixture() {
    const [owner, participant] = await ethers.getSigners();

    const SupplyChain = await ethers.getContractFactory("SupplyChain");
    const supplyChain = await SupplyChain.deploy([owner.address]);

    return { supplyChain, owner, participant };
  }



  // beforeEach(async function () {
  //   [owner, participant] = await ethers.getSigners();
  //   const SupplyChain = await ethers.getContractFactory("SupplyChain");
  //   supplyChain = await SupplyChain.deploy([owner.address]);
  //   await supplyChain.deployed();
  // });

  describe("createProduct", function () {
    it("should create a new product", async function () {
      const {  supplyChain, owner, participant } = await loadFixture(deployOneYearLockFixture);

      await supplyChain.createProduct(productName, productDescription);
      const product = await supplyChain.products(1);
      expect(product.name).to.equal(productName);
      expect(product.description).to.equal(productDescription);
      expect(product.productId).to.equal(1);
      expect(product.currentOwner).to.equal(owner.address);
      expect(product.status).to.equal("Created");
      expect(product.location).to.equal("");
      expect(product.timestamp).to.not.be.null;
      expect(product.eventCount).to.equal(0);
    });
  });

  describe("transferOwnership", function () {
    it("should transfer ownership of a product", async function () {
      const {  supplyChain, owner, participant } = await loadFixture(deployOneYearLockFixture);

      await supplyChain.createProduct(productName, productDescription);
      await supplyChain.addParticipant(owner.address);
      await supplyChain.getParticipant(owner.address)
     await supplyChain.transferOwnership(1, participant.address, "Transferred", "Location 1");
      const product = await supplyChain.products(1);
      expect(product.currentOwner).to.equal(participant.address);
      expect(product.status).to.equal("Transferred");
      expect(product.location).to.equal("Location 1");
      expect(product.timestamp).to.not.be.null;
      expect(product.eventCount).to.equal(0);
    });

    it("should revert if called by a non-owner", async function () {
      const {  supplyChain, participant } = await loadFixture(deployOneYearLockFixture);
      await supplyChain.addParticipant(participant.address);

      await supplyChain.createProduct(productName, productDescription);
      await expect(supplyChain.connect(participant).transferOwnership(1, participant.address, "Transferred", "Location 1"))
        .to.be.revertedWith("Only the current owner can transfer ownership");
    });
  });

  describe("addEvent", function () {
    it("should add a new event to a product", async function () {
      const {  supplyChain, owner, participant } = await loadFixture(deployOneYearLockFixture);
      await supplyChain.addParticipant(participant.address);
      await supplyChain.addParticipant(owner.address);

      await supplyChain.createProduct(productName, productDescription);
      await supplyChain.transferOwnership(1, participant.address, "Transferred", "Location 1");
      await supplyChain.connect(participant).addEvent(1, "Event 1", "Location 2");
      let product = await supplyChain.products(1);
      expect(product.eventCount).to.equal(1);
      await supplyChain.connect(participant).addEvent(1, "Event 2", "Location 2");
      product = await supplyChain.products(1);
      expect(product.eventCount).to.equal(2);
      const event = await supplyChain.getProductEvents(1);
      expect(event.length).to.equal(2);
     });
  });
});

// hardhat.config.ts
import { task } from "hardhat/config"; // import function
import "@nomiclabs/hardhat-waffle"; // change require to import

task("accounts", "Hello World", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.address);
  }
});

export default {
  solidity: "0.8.4",
};

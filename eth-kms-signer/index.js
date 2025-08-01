require('dotenv').config();

const { KMSClient } = require("@aws-sdk/client-kms");
const { KMSSigner } = require('@rumblefishdev/eth-signer-kms');
const { ethers } = require('ethers');

async function main() {
  const kms = new KMSClient({ region: process.env.AWS_REGION });

  const provider = new ethers.JsonRpcProvider(process.env.ETH_RPC_URL);
  const signer = await KMSSigner.create(provider, process.env.KMS_KEY_ID, kms);

  const address = await signer.getAddress();
  console.log("Using address:", address);

  const tx = await signer.sendTransaction({
    to: process.env.ETH_TXN_RECPIENT,
    value: ethers.parseEther("0.01"),
  });

  console.log("TX sent:", tx.hash);
  await tx.wait();
  console.log("TX confirmed.");
}

main().catch(console.error);

require('dotenv').config();

const { AwsKmsSigner } = require('eth-signer-kms');
const { ethers } = require('ethers');

async function main() {
  const provider = new ethers.JsonRpcProvider(process.env.ETH_RPC_URL);
  const signer = new AwsKmsSigner({
    keyId: process.env.KMS_KEY_ID,
    region: process.env.AWS_REGION,
    provider,
  });

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

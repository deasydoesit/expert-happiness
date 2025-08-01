import { AwsKmsSigner } from 'eth-signer-kms';
import { ethers } from 'ethers';
import * as dotenv from 'dotenv';

dotenv.config();

const main = async () => {
  const provider = new ethers.JsonRpcProvider(process.env.ETH_RPC_URL);
  const signer = new AwsKmsSigner({
    keyId: process.env.KMS_KEY_ID,
    region: process.env.AWS_REGION,
    provider,
  });

  const from = await signer.getAddress();
  console.log("From address:", from);

  const tx = await signer.sendTransaction({
    to: process.env.ETH_TXN_RECPIENT,
    value: ethers.parseEther("0.01"),
  });

  console.log("Sent tx:", tx.hash);
  await tx.wait();
  
  console.log("Confirmed.");
};

main().catch(console.error);

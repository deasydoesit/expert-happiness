require('dotenv').config();

const Fastify = require('fastify');
const { KMSClient } = require("@aws-sdk/client-kms");
const { KMSSigner } = require('@rumblefishdev/eth-signer-kms');
const { ethers } = require('ethers');
const metricsPlugin = require('fastify-metrics');

const fastify = Fastify({ logger: true });
const kms = new KMSClient({ region: process.env.AWS_REGION });
const provider = new ethers.JsonRpcProvider(process.env.ETH_RPC_URL);


(async () => {
  await fastify.register(metricsPlugin, { endpoint: '/metrics' });

  // POST /send?address=<recipient>
  fastify.post('/send', async (request, reply) => {
    const { address } = request.query;

    if (!ethers.isAddress(address)) {
      return reply.status(400).send({ error: 'Invalid Ethereum address' });
    }

    try {
      const signer = await KMSSigner.create(provider, process.env.KMS_KEY_ID, kms);

      const sender = await signer.getAddress();
      console.log("Using address:", sender);

      const tx = await signer.sendTransaction({
        to: address,
        value: ethers.parseEther("0.0001"),
      });

      console.log("TX sent:", tx.hash);
      await tx.wait();
      console.log("TX confirmed.");

      return reply.send({
        from: sender,
        to: address,
        hash: tx.hash,
        status: 'Transaction sent and confirmed',
      });
    } catch (err) {
      request.log.error(err);
      return reply.status(500).send({ error: 'Signing or sending transaction failed' });
    }
  });

  fastify.get('/wallet', async (request, reply) => {
    try {
      const signer = await KMSSigner.create(provider, process.env.KMS_KEY_ID, kms);
      const address = await signer.getAddress();
      return reply.send({ address });
    } catch (err) {
      request.log.error(err);
      return reply.status(500).send({ error: 'Failed to retrieve KMS wallet address' });
    }
  });

  try {
    await Promise.all([fastify.listen({ port: 3000, host: '0.0.0.0' })]);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
})();
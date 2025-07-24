import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
require('dotenv').config();

const JackpotModule = buildModule('JackpotModule', (m) => {
  // Platform adresini parametre olarak almak isteyebilirsin
  const platformAddress = m.getParameter('platformAddress', process.env.PLATFORM_ADDRESS as string);

  const jackpot = m.contract('Jackpot', [platformAddress]);

  return { jackpot };
});

export default JackpotModule;



// to deploy it on testnet
/*
    npx hardhat ignition deploy ./ignition/modules/Jackpot.ts --network flowTestnet
*/



// to verify the contract 
/*
    npx hardhat ignition verify chain-545 --include-unrelated-contracts
*/
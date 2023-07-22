# OpenMarket

A public good marketplace contracts with full onchain data to trade NFTs without platform fees nor API key.

## Why

### NFT Royalties Are Dead
The major marketplaces such as Blur, OpenSea, and Magic Eden have recently stopped enforcing NFT royalties as standard. This zero-roalty battle has killed the model that allowed creators to release NFTs for free or at a low cost and earn royalties.
### Off-Chain Order Books Are Hard To Access
Leading NFT platforms have implemented off-chain order books that are not publicly accessible. To integrate with these marketplaces, projects have to request API keys, like in web 2.0, and the approval process can take several months.
### Limited Distribution Channels
The existing NFT marketplaces have positioned themselves as "the distributors" of NFT collections. They decide on the rules, service fees, access to data and so on.

## Solution

- Online marketplace contract
- Public good: No marketplace fee ever, no admins, immutable contracts.
- Fully onchain orderbook

## Goals

- Sell NFT: less than 100k gas **done**
- Buy NFT: less than 100k gas (without fees, 103k with fees) **done**

## Properties

- Immutable: No admin key and no governance

## Roadmap

- Test factory **done**
- Collection transfer fees _prototype_
- Use Oracle to get the address of the deployer of a contract
- Sign on another chain, `buyWithSignature`

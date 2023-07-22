# OpenMarket

A public good NFT Marketplace.

## Why

Royalties are dead. Leading marketplaces have offchain orderbooks and we have to
beg for API keys like it's web 2.0.

We can kill two birds with one stone:

- Online marketplace
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

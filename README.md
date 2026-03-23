# Social Production Games

Revenue-generating onchain experiments on Base. First project: **Micro-Factory** (ERC-1155 production & marketplace).

## Contract: SocialFactory

- ERC-1155 token for factories (type 0) and goods (type 1)
- Mint factory (levels 1–5)
- Produce goods: cooldown = 24h / level
- Sell goods: fee set by owner (default 2.5%)
- Fees collected to owner wallet

## Deploy

```bash
export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"
export PRIVATE_KEY="0x..."
forge script script/DeploySocialFactory.s.sol:DeploySocialFactory \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

**Deployed on Base Sepolia:**
- Contract: `0x7aBEEDe541b425F8Ddb6014A427A21c194AE152d`
- Basescan: https://sepolia.basescan.org/address/0x7aBEEDe541b425F8Ddb6014A427A21c194AE152d

## Frontend

A static dashboard is provided in `frontend/index.html`. Deploy to Vercel/Netlify with root set to `frontend`. The contract address is already configured.

**Live frontend:** https://frontend-5z3j7qrgr-nikayrezzas-projects.vercel.app

### Features

- Connect wallet (MetaMask)
- Mint factory (level 1–5)
- Produce goods (cooldown 24h/level)
- Sell goods (ETH price, 2.5% fee to owner)
- View factory tree
- Automatic network check (Base Sepolia)

## Revenue Model

- Marketplace fee on each sale (configurable, default 2.5%)
- Fees are sent directly to the contract owner (deployer)
- Owner can withdraw accumulated ETH at any time

## Roadmap

- ERC-20 token for in-game currency
- The Graph indexing for production history
- Upgradeable contracts (proxy pattern)
- NFTs for factory skins/upgrades
- Cross-chain expansion to Base Mainnet

## License

MIT

# DUEWEAVE

DUEWEAVE is an original BOT Chain invoice-funding workspace. It lets an issuer hash a private invoice reference, publish the face value and discount, receive pooled BOT funding, draw after full funding, repay the face value, and let funders claim settlement proportionally.

## Local development

```bash
npm install
copy .env.example .env
npm run dev
```

Until `VITE_DUEWEAVE_ADDRESS` is configured, the interface stays in clearly labelled preview mode and never presents sample actions as real transactions.

## Wallet support

- EIP-6963 multi-wallet discovery
- legacy injected-wallet fallback
- explicit wallet chooser instead of silently selecting the first provider
- BOT Chain switch/add flow (chain ID 677)
- mobile MetaMask deep link when no injected wallet is found
- contract bytecode verification before live data is loaded

This prototype has not been professionally audited. Use small test amounts first.

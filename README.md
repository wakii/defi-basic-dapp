# Pab Token Vendor Project

## TL;DR 
- Demo : https://wakii-vendor.surge.sh/
- Code : https://rinkeby.etherscan.io/address//0xf163EE8639bBF85065c635358b4d407948710261
- deployed at Rinkeby

---
## Vendor

- `Constructor` 
    - initiated with ERC20 token address

- `buyTokens` 
    - receive eth and returns erc20 tokens
    - should be called after this contract has enough tokens with following ways
        - tokens being sold from the token owner to vendor contract
        - being transfered the tokens manually
    

- `sellTokens`
    - Receive erc20 from the seller and give back ETH to the seller.
    - Should have enough ether value to pay back to the seller and the seller had approved the contract to get erc20.

- `withdraw`
    - contract owner can withdraw all the ETH from token Vendor

## TODO
- add other erc20 tokens 
    -  by mapping tokenId and the erc20 contract address, buyer and seller can trade with their options
    


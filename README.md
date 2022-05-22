# Pab Token Vendor Project

## TL;DR 
- Demo : https://wakii-dex-v1.surge.sh/
- Code : https://rinkeby.etherscan.io/address/0x0d57612Ec25FBaECbC96578CB8D00bC5F3c29BEB
- deployed at Rinkeby

- AMM for Single Token Pair using XYK logic suggested by Vitalk Buterin.

---
## Vendor

- `Constructor` 
    - initiated with ERC20 token interface

- `init` 
    - could be called only when totalLiquidity equals to 0 to avoid no liquidity by transfering Balloons tokens to dex.
    - DEX contract has liquidity of [ether - token] pair.
    

- `price`
    - calculate the how much token(or ether) could be get.
    - ( amount of ETH in DEX ) * ( amount of tokens in DEX ) = k
    - Dex takes 0.3% of the input for swapping.

- `ethToToken`
    - Return Tokens by receiving ether calculated by 'price' function.

- `tokenToEth`
    - Return Ethers by receiving tokens calculated by 'price' function.

- `deposit`
    - By Receivieng ETH, swap some ethers to token and put this liquidity pair
    - totalLiquidity increase. In other words, adds K values in XYK.
    - tokenDeposit == eth_value * (price of ether with respect to token)
    - liquidityMinted == eth_value (price of ethReserve w.r.t totalLiquidity)

- `withdraw`
    - By Receiving Liquidity, returns ETH and Tokens to liquidity provider.
    - totalLiquidity decrease.
    - eth_amount == liquidity_amount * (price of totalLiquidity w.r.t ETH balance)
    - token_amount == liquidity_amount  * (price of totalLiquidity w.r.token balance)

## TODO
- add function to get other erc20 tokens 
    -  by mapping tokenId and the erc20 contract address, buyer and seller can trade with their options
    - like Uniswap-V2
    


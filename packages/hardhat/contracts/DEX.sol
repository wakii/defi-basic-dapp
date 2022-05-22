// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DEX {
    /* ========== GLOBAL VARIABLES ========== */

    using SafeMath for uint256; //outlines use of SafeMath for uint256 variables
    IERC20 token; //instantiates the imported contract

    uint256 public totalLiquidity;
    mapping (address => uint256) public liquidity;

    /* ========== EVENTS ========== */

    /**
     * @notice Emitted when ethToToken() swap transacted
     */
    event EthToTokenSwap(address trader, string ethToToken, uint256 value, uint256 tokenOutput);

    /**
     * @notice Emitted when tokenToEth() swap transacted
     */
    event TokenToEthSwap(address trader, string tokenToEth, uint256 value, uint256 tokenInput);

    /**
     * @notice Emitted when liquidity provided to DEX and mints LPTs.
     */
    event LiquidityProvided(address provider, uint256 mintedLiquidity, uint256 value, uint256 tokenDeposit);

    /**
     * @notice Emitted when liquidity removed from DEX and decreases LPT count within DEX.
     */
    event LiquidityRemoved(address withdrawer, uint256 liq_amount, uint256 eth_amount, uint256 token_amount);



    /* ========== CONSTRUCTOR ========== */

    constructor(address token_addr) {
        token = IERC20(token_addr); 
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice initializes amount of tokens that will be transferred to the DEX itself from the erc20 contract mintee (and only them based on how Balloons.sol is written). Loads contract up with both ETH and Balloons.
     * @param tokens amount to be transferred to DEX
     * @return totalLiquidity is the number of LPTs minting as a result of deposits made to DEX contract
     * NOTE: since ratio is 1:1, this is fine to initialize the totalLiquidity (wrt to balloons) as equal to eth balance of contract.
     */
    function init(uint256 tokens) public payable returns (uint256) {
        require(totalLiquidity == 0, "DEX: init - already has liquidity");
        totalLiquidity = address(this).balance;
        liquidity[msg.sender] = totalLiquidity;

        // need 'approve' transaction for DEX contract to take balloons from msg.sender.
        require(token.transferFrom(msg.sender, address(this), tokens), "DEX: init - transfer did not transact");
        return totalLiquidity;
    }

    /**
     * @notice returns yOutput, or yDelta for xInput (or xDelta)
     * @dev Follow along with the [original tutorial](https://medium.com/@austin_48503/%EF%B8%8F-minimum-viable-exchange-d84f30bd0c90) Price section for an understanding of the DEX's pricing model and for a price function to add to your contract. You may need to update the Solidity syntax (e.g. use + instead of .add, * instead of .mul, etc). Deploy when you are done.
     * NOTE: ( amount of ETH in DEX ) * ( amount of tokens in DEX ) = k
     *        k : invariant, which dosen't change during trades, (or swap). it only changes as liquidity as added.(should be adlusted by market and MM).
     */
    function price(
        uint256 xInput,
        uint256 xReserves,
        uint256 yReserves
    ) public pure returns (uint256 yOutput) {
        uint256 xInputWithFee = xInput * 997;    // fee 0.3%, no decimal by Solidity. 
        uint256 numerator = xInputWithFee * yReserves; 
        uint256 denominator = xReserves * 1000 + xInputWithFee; 
        return (numerator / denominator); 
    }

    /**
     * @notice returns liquidity for a user. Note this is not needed typically due to the `liquidity()` mapping variable being public and having a getter as a result. This is left though as it is used within the front end code (App.jsx).
     */
    function getLiquidity(address lp) public view returns (uint256) {
        return liquidity[lp];
    }

    /**
     * @notice sends Ether to DEX in exchange for $BAL
     */
    function ethToToken() public payable returns (uint256) {
        require(msg.value > 0, "DEX - ethToToken: Need ETH more than 0");
        uint256 ethReserves = address(this).balance - msg.value;
        uint256 tokenReserves = token.balanceOf(address(this));
        uint256 tokenOutput = price(msg.value, ethReserves, tokenReserves);
        require(token.transfer(msg.sender, tokenOutput), "DEX - ethToToken: failed");
        emit EthToTokenSwap(msg.sender, "ETH To Balloons", msg.value, tokenOutput);
        return tokenOutput;
    }

    /**
     * @notice sends $BAL tokens to DEX in exchange for Ether
     */
    function tokenToEth(uint256 tokenInput) public returns (uint256) {
        require(tokenInput > 0, "DEX - tokenToEth: Need token more than 0");
        uint256 tokenReserves = token.balanceOf(address(this));
        uint256 ethReserves = address(this).balance;
        uint256 ethOutput = price(tokenInput, tokenReserves, ethReserves);
        require(token.transferFrom(msg.sender, address(this), tokenInput), "DEX: tokenToEth: failed in token sending");
        (bool success,) = msg.sender.call{value: ethOutput}("");
        require(success, "DEX: tokenToEth: failed in eth transferring");
        emit TokenToEthSwap(msg.sender, "Balloons to ETH", ethOutput, tokenInput);
        return ethOutput;
    }

    /**
     * @notice allows deposits of $BAL and $ETH to liquidity pool
     * NOTE: parameter is the msg.value sent with this function call. That amount is used to determine the amount of $BAL needed as well and taken from the depositor.
     * NOTE: user has to make sure to give DEX approval to spend their tokens on their behalf by calling approve function prior to this function call.
     * NOTE: Equal parts of both assets will be removed from the user's wallet with respect to the price outlined by the AMM.
     */
    function deposit() public payable returns (uint256) {
        require(msg.value > 0, "DEX - deposit : msg.value should be more than 0");
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = token.balanceOf(address(this));

        uint256 tokenDeposit = msg.value * tokenReserve / ethReserve;
        uint256 liquidityMinted = msg.value * totalLiquidity / ethReserve; // new ETH input * (price of ethReserve w.r.t totalLiquidity)
        liquidity[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;

        require(token.transferFrom(msg.sender, address(this), tokenDeposit), "DEX: deposit - token failed to transfer");
        emit LiquidityProvided(msg.sender, liquidityMinted, msg.value, tokenDeposit);
        return tokenDeposit;
    }

    /**
     * @notice allows withdrawal of $BAL and $ETH from liquidity pool
     * NOTE: with this current code, the msg caller could end up getting very little back if the liquidity is super low in the pool. I guess they could see that with the UI.
     */
    function withdraw(uint256 liq_amount) public returns (uint256, uint256) {
        require(liquidity[msg.sender] >= liq_amount, "DEX: withdraw: - User has less liquidity token in the pool");
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 eth_amount = liq_amount * address(this).balance / totalLiquidity;  // liquidity_amount * (price of totalLiquidity w.r.t ETH balance)
        uint256 token_amount = liq_amount * tokenReserve / totalLiquidity;
        liquidity[msg.sender] -= liq_amount;
        totalLiquidity -= liq_amount;
        (bool success, ) = msg.sender.call{value: eth_amount}("");
        require(success, "Failed to send user eth");
        require(token.transfer(msg.sender, token_amount), "Failed to send user token");
        emit LiquidityRemoved(msg.sender, liq_amount, eth_amount, token_amount);
        return (eth_amount, token_amount);
    }
}

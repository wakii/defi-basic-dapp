# Pab Staking Project

## TL;DR
- Demo : https://wakii-staking.surge.sh/
- Code : https://rinkeby.etherscan.io/address/0xd4c21b31Eed8dEC718016DCE5fBC35F7514C47F3
- deployed at Rinkeby

---

### Staker
- EOA on rinkeby can stake their RINKEBY ether to this contract.
- Since Ethereum is a transaction based State Machine, this staking app works as well with a 'staking' period.

- `constructor`
    - initiated with an address of `exampleExternalContract` which is example treasury.


- `stake`
    - Staking can be possible within the staking time remains.
    - the time is calculated with blockstamp time and the deadline of 10 days.
- `execute`
    - If deadline passed and the staked ether is over than the threshold 1eth, the staking is completed.
    - The staker calls treasury contract with sending all the balance of this contract

- `withdraw`
    - If the deadline passed but staking services is not completed, the user who staked can unstake and withdrawed their staked ether.
    - By setting balance of msg.sender be 0 first followed by transfering ether back, Reentrancy Attack is being avoid.


- `receive`
    - since 'stake' is payable, this contract has 'receive` function.
    - if EOA transfers only their ether without calling 'stake' tx, the 'stake' function will be called.
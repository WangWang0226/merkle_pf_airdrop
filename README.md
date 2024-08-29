
### Introduction

The **Airdrop** contract is designed to facilitate the distribution of tokens to a predetermined list of recipients in a decentralized and secure manner. It employs a **Merkle tree** structure to efficiently and securely manage airdrop claims, ensuring that only eligible recipients can claim their tokens. The contract also provides functionalities for managing the airdrop period, ownership, and withdrawal of unclaimed tokens.

### Key Features

1. **Merkle Tree-Based Airdrop Verification**:  
   The contract uses a **Merkle tree** to verify the eligibility of recipients claiming tokens. A Merkle tree is a data structure that allows the efficient and secure verification of elements in a large dataset. In this context, the Merkle tree contains the addresses and claimable amounts of all eligible recipients. The root of this tree, known as the **Merkle root**, is stored in the contract (`merkleRoot`). When a user wants to claim their tokens, they must provide a **Merkle proof**—a set of hashes that verify their inclusion in the tree. This proof is used in the `claim` function to validate the user's eligibility without needing to store the entire list on-chain, thereby saving gas costs.

2. **Claim Status Tracking with Bitmaps**:  
   The contract employs a **bitmap mechanism** to efficiently track which recipients have claimed their tokens. This mechanism is implemented using the `claimedBitMap` mapping. Each bit in this bitmap represents whether a particular index in the Merkle tree has been claimed. The `isClaimed` function checks if a specific index has already been claimed by examining the corresponding bit in the bitmap. If the bit is set (i.e., equal to 1), it indicates that the tokens for that index have already been claimed, preventing double-claims. If not, the `_setClaimed` function sets the corresponding bit to mark the index as claimed when the user successfully claims their tokens.

3. **Flexible Airdrop Management**:  
   - **Configurable Airdrop Period**: The contract owner can set or modify the start (`claimStartTime`) and end (`claimEndTime`) times for the airdrop. Claims can only be made during this period.
   - **Owner Withdrawal**: After the airdrop period ends, the contract owner can withdraw any unclaimed tokens.
   - **Ownership Transfer**: The owner of the contract has the ability to transfer ownership to a new address, allowing for decentralized management and control.

### How It Works

1. **Initialization**:
   - The contract is initialized with the owner's address, the address of the token to be airdropped (`airdropToken`), the `merkleRoot` that represents the set of eligible claims, and the start and end times for the claim period.

2. **Claiming Airdrop Tokens**:
   - To claim tokens, a user must call the `claim` function with their index, address, amount of tokens, and a Merkle proof.
   - The contract first checks if the claim period is active and that the claim has not already been made using the `isClaimed` function.
   - It then verifies the Merkle proof against the stored `merkleRoot` to confirm the user's eligibility.
   - Upon successful verification, the contract marks the claim as claimed using `_setClaimed`, and transfers the specified amount of tokens to the user.

3. **Security and Efficiency**:
   - By using the Merkle tree and bitmap mechanism, the contract ensures that claims are processed securely and efficiently without needing to store large amounts of data on-chain.
   - The `onlyOwner` modifier is used to restrict certain functions, such as setting the Merkle root and withdrawing tokens, to the contract owner.

--- 

## Foundry

This repository uses Foundry as development framework.
**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

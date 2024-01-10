# Fungible Token Project on Flow Blockchain

Welcome to the Fungible Token Project repository. This repository is dedicated to a comprehensive implementation of a custom Fungible Token contract on the Flow blockchain, accompanied by a suite of transactions and scripts. The project is meticulously segmented into various parts, each focusing on different facets of token management and interactions.

## Overview

### Core Contract Implementation

**Contract - FlowToken:**
- Introduces the `FlowToken` contract encapsulating key features like:
  - Owner-controlled minting process.
  - A `Vault` resource for maintaining token balances.
  - An array of transactions and scripts for robust token management.

**Code Insights:**
- Highlights the `deposit` function within the `Vault` resource, ensuring secure token transfer and preventing double-counting through meticulous balance management.

### Fundamental Transactions and Scripts

**Transactions:**
- **MINT:** Facilitates the minting of tokens to designated recipients.
- **SETUP:** Streamlines the initialization of a user's vault in account storage.
- **TRANSFER:** Enables users to transfer tokens to different addresses.

**Scripts:**
- **READ BALANCE:** Retrieves the token balance in a user’s vault.
- **SETUP VALIDATION:** Confirms correct vault setup.
- **TOTAL SUPPLY CHECK:** Reports the total circulating supply of tokens.

### Transaction and Script Enhancements

**Focus:**
- Improving **SETUP** transaction for remedying improperly set up vaults.
- Enhancing **READ BALANCE** script for compatibility with non-standard vault setups.

**Key Features:**
- Resource identifiers for verifying token types.
- Resource capabilities for vault authenticity validation.

### Contract and Transaction Augmentation

**Admin Capabilities:**
- Empowers the `Admin` to withdraw tokens from user vaults and deposit equivalent $FLOW tokens.

**New Transaction:**
- **Admin Withdraw and Deposit:** Admin-exclusive transaction for token management.

### Advanced Scripting

**Scripts:**
- **BALANCE SUMMARY:** Presents a summary of a user’s $FLOW and custom token vault balances.
- **VAULT OVERVIEW:** Provides a detailed overview of all recognized Fungible Token vaults in a user’s storage.

### Swap Contract Integration

**Swap Contract:**
- The `Swap` contract is a pivotal feature allowing users to exchange $FLOW tokens for custom tokens, based on the duration since their last exchange.

**Swap Mechanics:**
- Utilizes a custom identity resource and user's $FLOW vault reference to authenticate user identity and facilitate secure token swaps.

## Project Conclusion

This repository exemplifies a full-fledged Fungible Token contract deployment on the Flow blockchain, showcasing an array of functionalities including token minting, vault setup, token transfer, and token swapping. The project is systematically structured for enhanced comprehensibility and ease of navigation.

For detailed guidelines and instructions, please refer to the individual code files and accompanying comments within this repository.

## Author

[Samuel Paul](https://github.com/samuepaul)

## Licensing

This project is released under the [MIT License](LICENSE), fostering open and collaborative development.
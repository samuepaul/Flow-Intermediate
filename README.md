# Fungible-Token-Project

This repository contains a Flow blockchain project implementing a custom Fungible Token contract and related transactions and scripts. The project is divided into several parts, each addressing specific aspects of token management and interactions.

## Part 1

### Contract

The custom Fungible Token contract is implemented in the `FlowToken` contract. It includes the following key features:

- Minting functionality controlled by the contract owner.
- Vault resource for storing token balances.
- Various transactions and scripts to manage tokens.

### Code Walk-Through

The `deposit` function within the `Vault` resource zeroes out the balance of an incoming vault before destroying it. This ensures that the vault's tokens are transferred and prevents double counting. When the new vault is created, it holds the transferred tokens, preventing loss of tokens during the transition.

## Part 2

### Transactions

- **MINT:** Mint tokens to a recipient.
- **SETUP:** Properly sets up a vault inside a user's account storage.
- **TRANSFER:** Allows a user to transfer tokens to a different address.

### Scripts

- **READ BALANCE:** Reads the balance of a user's vault.
- **SETUP CORRECTLY?:** Returns true if the user's vault is set up correctly and false if not.
- **TOTAL SUPPLY:** Returns the total supply of tokens in existence.

## Part 3

### Transactions and Scripts Modification

- **SETUP:** Identifies and fixes poorly set up vaults.
- **READ BALANCE:** Works with poorly set up vaults and temporarily fixes them to guarantee balance retrieval.

Guaranteeing balance retrieval involves:

1. Using resource identifiers to ensure the correct token type. 
2. Using resource capabilities to validate the authenticity of the vault.

## Part 4

### Contract Modification

The `Admin` is granted the ability to withdraw tokens from a user's vault and deposit equivalent $FLOW tokens.

### Transactions

- **Admin Withdraw and Deposit:** Allows the Admin to withdraw tokens and deposit $FLOW tokens.

## Part 5

### Scripts

- **Balance Summary:** Returns the balance of the user's $FLOW vault and custom vault.
- **Vault Overview:** Neatly returns information about all official Fungible Token vaults in the user's account storage.

## Part 6

### Swap Contract

The `Swap` contract enables users to deposit $FLOW tokens and receive custom tokens in return, with the received amount based on the time since their last swap.

### Swapping Functionality

Two methods are implemented to ensure user identity:

1. Using a custom identity resource to represent identity.
2. Using a reference to the user's $FLOW vault to prove authenticity.

## Conclusion

This Flow Token project demonstrates the implementation of a custom Fungible Token contract and its various functionalities. The repository includes contracts, transactions, and scripts for managing tokens, setting up vaults, transferring tokens, and swapping tokens. The code and functionalities have been organized into distinct parts to make the project more understandable and manageable.

For detailed usage and instructions, please refer to the individual code files and comments within the repository.

## Author

[Samuel Paul](https://github.com/samuepaul)

## License

This project is licensed under the [MIT License](LICENSE).
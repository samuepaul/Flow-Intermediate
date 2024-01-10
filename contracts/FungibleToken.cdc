/**
# Standard for Flow Fungible Tokens
## `TokenStandard` Contract Interface
This interface outlines the required structure for Fungible Token contracts on Flow.
Contracts deploying new tokens must implement this interface,
adhering to its specifications and naming conventions.
## `TokenStorage` Resource
Each token holder's account must contain an instance of the TokenStorage resource.
This resource offers methods accessible by the owner and other accounts.
## Interfaces: `TokenSupplier`, `TokenAcceptor`, and `TokenBalance`
These interfaces specify pre-conditions and post-conditions for Vault operations.
Separation of these interfaces allows sharing of Vault references with restricted access
and the creation of custom resources adhering to these interfaces for various token operations.
Token transfers can be peer-to-peer without a central ledger contract: users withdraw tokens from
their TokenStorage and deposit them into another's.
*/

/// Interface for Fungible Token contracts.
pub contract interface TokenStandard {

    /// Total existing tokens. Implementers must keep this updated.
    pub var supplyTotal: UFix64

    /// Event on contract creation
    pub event ContractActivated(initialTokens: UFix64)

    /// Event for token withdrawals from a TokenStorage
    pub event TokenWithdrawal(quantity: UFix64, origin: Address?)

    /// Event for token deposits into a TokenStorage
    pub event TokenDeposit(quantity: UFix64, destination: Address?)

    /// Interface for token withdrawals.
    pub resource interface TokenSupplier {

        /// Removes tokens from a TokenStorage, returning a new TokenStorage with those tokens.
        ///
        /// Accessible by the owner or delegated users via private or public capabilities.
        ///
        /// @param quantity: Amount to withdraw
        /// @return TokenStorage with withdrawn tokens
        pub fun withdraw(quantity: UFix64): @TokenStorage {
            post {
                result.tokenAmount == quantity:
                    "Withdrawn quantity should match the new TokenStorage's token amount"
            }
        }
    }

    /// Interface for token deposits.
    pub resource interface TokenAcceptor {

        /// Deposits a TokenStorage's tokens into this type.
        ///
        /// @param from: TokenStorage with funds for deposit
        pub fun deposit(from: @TokenStorage)

        /// Returns the types of TokenStorage that can be deposited.
        /// Default implementations return an empty dictionary.
        ///
        /// @return Dictionary of acceptable TokenStorage types
        ///
    }

    /// Interface containing the `tokenAmount` field and ensuring correct initialization.
    pub resource interface TokenBalance {

        /// Token balance in the TokenStorage
        pub var tokenAmount: UFix64

        init(startingAmount: UFix64) {
            post {
                self.tokenAmount == startingAmount:
                    "Initial amount must match the starting amount"
            }
        }
    }

    /// The TokenStorage resource, defining token transfer mechanics.
    /// Must conform to `TokenSupplier`, `TokenAcceptor`, and `TokenBalance`.
    pub resource TokenStorage: TokenSupplier, TokenAcceptor, TokenBalance {

        /// Balance of tokens in the storage
        pub var tokenAmount: UFix64

        /// Initialize with a starting token amount.
        init(startingAmount: UFix64)

        /// Withdraws a specified token amount, returning a new TokenStorage.
        pub fun withdraw(quantity: UFix64): @TokenStorage {
            pre {
                self.tokenAmount >= quantity:
                    "Withdrawal amount must be less than or equal to the storage's token amount"
            }
            post {
                self.tokenAmount == before(self.tokenAmount) - quantity:
                    "New balance should be the original minus the withdrawal amount"
            }
        }

        /// Deposits tokens from a given TokenStorage.
        pub fun deposit(from: @TokenStorage) {
            pre {
                from.isInstance(self.getType()): 
                    "Deposited token type must match the storage's token type"
            }
            post {
                self.tokenAmount == before(self.tokenAmount) + before(from.tokenAmount):
                    "New balance should be the sum of the original and deposited amounts"
            }
        }
    }

    /// Creates a new TokenStorage with zero balance.
    pub fun createEmptyTokenStorage(): @TokenStorage {
        post {
            result.tokenAmount == 0.0: "Newly created TokenStorage should have zero balance"
        }
    }
}

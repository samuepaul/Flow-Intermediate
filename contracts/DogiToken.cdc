import FungibleToken from 0x05

// CanineCoin Contract: This contract on the Flow blockchain is a fungible token implementation
pub contract CanineCoin: FungibleToken {

    // Keeping track of the total number of tokens
    pub var supplyTotal: UFix64
    // List for managing vault identifiers
    pub var vaultIdentifiers: [UInt64]

    // Token-related events
    pub event InitialTokenSupply(supply: UFix64)
    pub event TokenExtraction(quantity: UFix64, origin: Address?)
    pub event TokenInsertion(quantity: UFix64, destination: Address?)

    // Interface for the Vault resource accessible publicly
    pub resource interface VaultAccess {
        pub var tokenBalance: UFix64
        pub fun addTokens(tokenVault: @FungibleToken.Vault)
        pub fun removeTokens(quantity: UFix64): @FungibleToken.Vault
        access(contract) fun forceRemoveTokens(quantity: UFix64): @FungibleToken.Vault
    }

    // The Vault resource definition
    pub resource VaultStorage: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, VaultAccess {
        pub var tokenBalance: UFix64

        // Vault initialization with a specific balance
        init(startingBalance: UFix64) {
            self.tokenBalance = startingBalance
        }

        // Function to take out tokens from the vault
        pub fun removeTokens(quantity: UFix64): @FungibleToken.Vault {
            self.tokenBalance = self.tokenBalance - quantity            
            emit TokenExtraction(quantity: quantity, origin: self.owner?.address)
            return <-create VaultStorage(balance: quantity)
        }

        // Function for depositing tokens into the vault
        pub fun addTokens(tokenVault: @FungibleToken.Vault) {
            let tempVault <- tokenVault as! @CanineCoin.VaultStorage
            emit TokenInsertion(quantity: tempVault.tokenBalance, destination: self.owner?.address)
            self.tokenBalance = self.tokenBalance + tempVault.tokenBalance
            tempVault.tokenBalance = 0.0
            destroy tempVault
        }

        // Contract access for forced token withdrawal
        access(contract) fun forceRemoveTokens(quantity: UFix64): @FungibleToken.Vault {
            self.tokenBalance = self.tokenBalance - quantity
            return <-create VaultStorage(balance: quantity)
        }

        // Vault destruction logic
        destroy() {
            CanineCoin.supplyTotal = CanineCoin.supplyTotal - self.tokenBalance
        }
    }

    // Definition of the Admin resource
    pub resource Administrator {
        // Admin capability: Extract tokens from a specified vault
        pub fun extractTokens(vault: &VaultStorage{VaultAccess}, quantity: UFix64): @FungibleToken.Vault {
            return <-vault.forceRemoveTokens(quantity: quantity)
        }
    }

    // Minter resource for creating new tokens
    pub resource TokenMinter {
        // Admin function to generate new tokens
        pub fun createNewTokens(quantity: UFix64): @FungibleToken.Vault {
            CanineCoin.supplyTotal = CanineCoin.supplyTotal + quantity
            return <-create VaultStorage(balance: quantity)
        }
    }

    init() {
        // Initializing the contract with zero supply and necessary resources
        self.supplyTotal = 0.0
        self.account.save(<-create TokenMinter(), to: /storage/MinterStorage)
        self.account.link<&CanineCoin.TokenMinter>(/public/MinterLink, target: /storage/MinterStorage)
        self.account.save(<-create Administrator(), to: /storage/AdminStorage)
        self.vaultIdentifiers = []
        emit InitialTokenSupply(supply: self.supplyTotal)
    }

    // Function to create a new, empty Vault
    pub fun initializeVault(): @FungibleToken.Vault {
        let newVault <- create VaultStorage(balance: 0.0)
        self.vaultIdentifiers.append(newVault.uuid)
        return <-newVault
    }
}

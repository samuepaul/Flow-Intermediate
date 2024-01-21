import FungibleToken from 0x05

// DogiToken Contract on Flow Blockchain
pub contract DogiToken: FungibleToken {

    // Token State Variables
    pub var supplyTotal: UFix64       // Total supply of tokens
    pub var vaultIdentifiers: [UInt64] // List of vault identifiers

    // Token Events
    pub event InitialTokenSupply(supply: UFix64)
    pub event TokenExtraction(quantity: UFix64, origin: Address?)
    pub event TokenInsertion(quantity: UFix64, destination: Address?)

    // Vault Resource Interface
    pub resource interface VaultAccess {
        pub var tokenBalance: UFix64
        pub fun addTokens(tokenVault: @FungibleToken.Vault)
        pub fun removeTokens(quantity: UFix64): @FungibleToken.Vault
        access(contract) fun forceRemoveTokens(quantity: UFix64): @FungibleToken.Vault
    }

    // Vault Resource
    pub resource VaultStorage: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, VaultAccess {
        pub var tokenBalance: UFix64

        // Initialize Vault with balance
        init(startingBalance: UFix64) {
            self.tokenBalance = startingBalance
        }

        // Add tokens to the vault
        pub fun addTokens(tokenVault: @FungibleToken.Vault) {
            let tempVault <- tokenVault as! @DogiToken.VaultStorage
            self.tokenBalance = self.tokenBalance + tempVault.tokenBalance
            emit TokenInsertion(quantity: tempVault.tokenBalance, destination: self.owner?.address)
            tempVault.tokenBalance = 0.0
            destroy tempVault
        }

        // Remove tokens from the vault
        pub fun removeTokens(quantity: UFix64): @FungibleToken.Vault {
            self.tokenBalance = self.tokenBalance - quantity
            emit TokenExtraction(quantity: quantity, origin: self.owner?.address)
            return <-create VaultStorage(startingBalance: 0.0)
        }

        // Force removal of tokens (internal contract use)
        access(contract) fun forceRemoveTokens(quantity: UFix64): @FungibleToken.Vault {
            self.tokenBalance = self.tokenBalance - quantity
            return <-create VaultStorage(startingBalance: 0.0)
        }

        // Vault destruction logic
        destroy() {
            DogiToken.supplyTotal = DogiToken.supplyTotal - self.tokenBalance
        }

        // Additional methods required by FungibleToken.Balance interface
        pub fun balance(): UFix64 {
            return self.tokenBalance
        }

        // Additional methods required by FungibleToken.Receiver interface
        pub fun deposit(amount: UFix64) {
            self.tokenBalance = self.tokenBalance + amount
        }

        // Additional methods required by FungibleToken.Provider interface
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.tokenBalance = self.tokenBalance - amount
            return <-create VaultStorage(startingBalance: amount)
        }
    }

    // Administrator Resource
    pub resource Administrator {
        // Extract tokens from a specified vault
        pub fun extractTokens(vault: &VaultStorage{VaultAccess}, quantity: UFix64): @FungibleToken.Vault {
            return <-vault.forceRemoveTokens(quantity: 0.0)
        }
    }

    // Token Minter Resource
    pub resource TokenMinter {
        // Create new tokens
        pub fun createNewTokens(quantity: UFix64): @FungibleToken.Vault {
            DogiToken.supplyTotal = DogiToken.supplyTotal + quantity
            return, <-create VaultStorage(startingBalance: 0.0)
        }
    }

    // Contract Initialization
    init() {
        self.supplyTotal = 0.0
        self.vaultIdentifiers = []

        // Resource initialization
        self.account.save(<-create TokenMinter(), to: /storage/MinterStorage)
        self.account.link<&DogiToken.TokenMinter>(/public/MinterLink, target: /storage/MinterStorage)
        self.account.save(<-create Administrator(), to: /storage/AdminStorage)

        // Emit initial supply event
        emit InitialTokenSupply(supply: self.supplyTotal)
    }

    // Create a new empty Vault
    pub fun initializeVault(): @FungibleToken.Vault {
        let newVault <- create VaultStorage(startingBalance: 0.0)
        self.vaultIdentifiers.append(newVault.uuid)
        return <-newVault
    }
}

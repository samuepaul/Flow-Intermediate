import FungibleToken from 0x05

// DogiToken contract: Implements fungible token on Flow blockchain
pub contract DogiToken: FungibleToken {

    // Total supply of tokens
    pub var totalSupply: UFix64
    // Array to store vault UUIDs
    pub var vaults: [UInt64]

    // Events
    pub event TokensInitialized(initialSupply: UFix64)
    pub event TokensWithdrawn(amount: UFix64, from: Address?)
    pub event TokensDeposited(amount: UFix64, to: Address?)

    // Vault resource interface
    pub resource interface CollectionPublic {
        pub var balance: UFix64
        pub fun deposit(from: @FungibleToken.Vault)
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault
        access(contract) fun adminWithdraw(amount: UFix64): @FungibleToken.Vault
    }

    // Vault resource
    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance, CollectionPublic {
        pub var balance: UFix64

        // Initialize vault balance
        init(balance: UFix64) {
            self.balance = balance
        }

        // Withdraw tokens from the vault
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount            
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        // Deposit tokens into the vault
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @DogiToken.Vault
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            self.balance = self.balance + vault.balance
            vault.balance = 0.0
            destroy vault
        }

        // Admin access: Force withdraw tokens
        access(contract) fun adminWithdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            return <-create Vault(balance: amount)
        }

        // Destroy the vault
        destroy() {
            DogiToken.totalSupply = DogiToken.totalSupply - self.balance
        }
    }

    // Admin resource
    pub resource Admin {
        // Admin function: Withdraw tokens from sender's vault
        pub fun adminGetCoin(senderVault: &Vault{CollectionPublic}, amount: UFix64): @FungibleToken.Vault {
            return <-senderVault.adminWithdraw(amount: amount)
        }
    }

    // Minter resource
    pub resource Minter {
        // Admin function: Mint new tokens
        pub fun mintToken(amount: UFix64): @FungibleToken.Vault {
            DogiToken.totalSupply = DogiToken.totalSupply + amount
            return <-create Vault(balance: amount)
        }
    }

    init() {
        // Initialize total supply and resources
        self.totalSupply = 0.0
        self.account.save(<-create Minter(), to: /storage/MinterStorage)
        self.account.link<&DogiToken.Minter>(/public/Minter, target: /storage/MinterStorage)
        self.account.save(<-create Admin(), to: /storage/AdminStorage)
        self.vaults = []
        emit TokensInitialized(initialSupply: self.totalSupply)
    }

    // Create an empty vault
    pub fun createEmptyVault(): @FungibleToken.Vault {
        let instance <- create Vault(balance: 0.0)
        self.vaults.append(instance.uuid)
        return <-instance
    }
}

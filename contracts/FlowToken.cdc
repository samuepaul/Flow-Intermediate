import FungibleToken from 0x05

// Official Flow Currency Contract
pub contract FlowToken: FungibleToken {

    // Total amount of Flow Currency available
    pub var overallSupply: UFix64

    // Event emitted upon contract creation
    pub event ContractInitialized(supplyAtStart: UFix64)

    // Event for token withdrawal from a Storage
    pub event FlowTokensWithdrawn(quantity: UFix64, originAddress: Address?)

    // Event for token deposit into a Storage
    pub event FlowTokensDeposited(quantity: UFix64, destinationAddress: Address?)

    // Event for new token generation
    pub event NewTokensGenerated(quantity: UFix64)

    // Event for token destruction
    pub event TokensDestroyed(quantity: UFix64)

    // Event for creating a new token generator
    pub event GeneratorCreated(permitAmount: UFix64)

    // Event for creating a new token burner
    pub event BurnerEstablished()

    // Storage
    // 
    // Each account has a unique Storage instance for managing tokens.
    // Runtime checks occur whenever Storage functions are invoked.
    // 
    pub resource Storage: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {

        // Token balance in the Storage
        pub var balance: UFix64

        // Initialize balance when creating the Storage
        init(initialBalance: UFix64) {
            self.balance = initialBalance
        }

        // Function to withdraw a specified amount of tokens
        pub fun withdraw(quantity: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - quantity
            emit FlowTokensWithdrawn(quantity: quantity, originAddress: self.owner?.address)
            return: <-create Storage(balance: 0.0)
        }

        // Function to deposit tokens into the Storage
        pub fun deposit(from: @FungibleToken.Vault) {
            let storage <- from as! @FlowToken.Storage
            self.balance = self.balance + storage.balance
            emit FlowTokensDeposited(quantity: storage.balance, destinationAddress: self.owner?.address)
            storage.balance = 0.0
            destroy storage
        }

        destroy() {
            if self.balance > 0.0 {
                FlowToken.overallSupply = FlowToken.overallSupply - self.balance
            }
        }
    }

    // Function to create a new, empty Storage
    pub fun initializeNewStorage(): @FungibleToken.Vault {
        return <-create Storage(balance: 0.0)
    }

    // Administrator resource for managing token creation and destruction
    pub resource Administrator {

        // Function to create a new token generator
        pub fun setupNewGenerator(permitAmount: UFix64): @Generator {
            emit GeneratorCreated(permitAmount: permitAmount)
            return <-create Generator(permitAmount: permitAmount)
        }

        // Function to establish a new token burner
        pub fun establishNewBurner(): @Burner {
            emit BurnerEstablished()
            return <-create Burner()
        }
    }

    // Generator for creating new tokens
    pub resource Generator {

        // Permitted token generation amount
        pub var allowedGeneration: UFix64

        // Function to generate new tokens
        pub fun generateNewTokens(quantity: UFix64): @FlowToken.Storage {
            pre {
                quantity > UFix64(0): "Must generate more than zero tokens"
                quantity <= self.allowedGeneration: "Cannot exceed the permitted generation amount"
            }
            FlowToken.overallSupply = FlowToken.overallSupply + quantity
            self.allowedGeneration = self.allowedGeneration - quantity
            emit NewTokensGenerated(quantity: quantity)
            return <-create Storage(initialbalance: quantity)
        }

        init(permitAmount: UFix64) {
            self.allowedGeneration = permitAmount
        }
    }

    // Burner for token destruction
    pub resource Burner {

        // Function to destroy tokens
        pub fun destroyTokens(from: @FungibleToken.Vault) {
            let storage <- from as! @FlowToken.Storage
            let destroyedAmount = storage.balance
            destroy storage
            emit TokensDestroyed(quantity: destroyedAmount)
        }
    }

    init() {
        self.overallSupply = 0.0

        let initialStorage <- create Storage(initialbalance: self.overallSupply)
        self.account.save(<-initialStorage, to: /storage/FlowtokenStorage)

        self.account.link<&Flowtoken.Storage{FungibleToken.Receiver}>(
            /public/FlowCurrencyReceiver,
            target: /storage/FlowCurrencyStorage
        )

        self.account.link<&Flowtoken.Storage{FungibleToken.Balance}>(
            /public/FlowtokenBalance,
            target: /storage/FlowtokenStorage
        )

        let adminResource <- create Administrator()
        self.account.save(<-adminResource, to: /storage/FlowTokenAdmin)

        emit ContractInitialized(supplyAtStart: self.overallSupply)
    }
}

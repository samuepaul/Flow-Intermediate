import FungibleToken from 0x05
import FlowToken from 0x05
import DogiToken from 0x05

// TokenExchanger contract: Enables exchanging DogiToken tokens with FlowCurrency
pub contract TokenExchanger {

    // Record of the most recent exchange timestamp for the contract
    pub var recentExchangeTimestamp: UFix64
    // Mapping to track each user's last exchange timestamp
    pub var userExchangeHistory: {Address: UFix64}

    // Method for exchanging tokens between DogiAsset and FlowCurrency
    pub fun exchangeTokens(account: AuthAccount, exchangeAmount: UFix64) {

        // Access DogiAsset and FlowCurrency storages from account
        let dogiTokenStorage = account.borrow<&DogiToken.Vault>(from: /storage/DogiTokenStorage)
            ?? panic("Could not access DogiToken Storage from account")

        let flowTokenStorage = account.borrow<&FlowToken.Vault>(from: /storage/FlowTokenStorage)
            ?? panic("Could not access FlowToken Storage from account")

        // Access DogiToken's Minter capability
        let minterAccess = account.getCapability<&Dogitoken.Minter>(/public/DogitokenMinter).borrow()
            ?? panic("Could not access Dogitoken Minter capability")

        // Access FlowToken vault for token operations
        let flowTokenOps = account.getCapability<&FlowCurrency.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>(/public/FlowCurrencyOps).borrow()
            ?? panic("Could not access FlowToken operations capability")

        // Perform token withdrawal and deposit
        let extractedTokens <- flowTokenStorage.withdraw(amount: exchangeAmount)
        flowTokenOps.deposit(from: <-extractedTokens)
        
        // Retrieve account address and current timestamp
        let accountAddress = account.address
        recentExchangeTimestamp = userExchangeHistory[accountAddress] ?? 1.0
        let currentTimestamp = getCurrentBlock().timestamp

        // Determine time elapsed since last exchange and calculate new token amount
        let elapsedSinceLastExchange = currentTimestamp - recentExchangeTimestamp
        let newTokenAmount = 2.0 * UFix64(elapsedSinceLastExchange)

        // Generate new DogiToken tokens and deposit into the storage
        let newDogiTokenStorage <- minterAccess.mintToken(amount: newTokenAmount)
        dogiTokenStorage.deposit(from: <-newDogiTokenStorage)

        // Update the exchange timestamp for the user
        userExchangeHistory[accountAddress] = elapsedSinceLastExchange
    }

    // Contract initialization
    init() {
        // Initialize timestamps
        recentExchangeTimestamp = 1.0
        userExchangeHistory = {0x05: 1.0}
    }
}

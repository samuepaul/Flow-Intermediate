import FungibleToken from 0x05
import FlowCurrency from 0x05
import DogiAsset from 0x05

// TokenExchanger contract: Enables exchanging DogiAsset tokens with FlowCurrency
pub contract TokenExchanger {

    // Record of the most recent exchange timestamp for the contract
    pub var recentExchangeTimestamp: UFix64
    // Mapping to track each user's last exchange timestamp
    pub var userExchangeHistory: {Address: UFix64}

    // Method for exchanging tokens between DogiAsset and FlowCurrency
    pub fun exchangeTokens(account: AuthAccount, exchangeAmount: UFix64) {

        // Access DogiAsset and FlowCurrency storages from account
        let dogiAssetStorage = account.borrow<&DogiAsset.Vault>(from: /storage/DogiAssetStorage)
            ?? panic("Could not access DogiAsset Storage from account")

        let flowCurrencyStorage = account.borrow<&FlowCurrency.Vault>(from: /storage/FlowCurrencyStorage)
            ?? panic("Could not access FlowCurrency Storage from account")

        // Access DogiAsset's Minter capability
        let minterAccess = account.getCapability<&DogiAsset.Minter>(/public/DogiAssetMinter).borrow()
            ?? panic("Could not access DogiAsset Minter capability")

        // Access FlowCurrency vault for token operations
        let flowCurrencyOps = account.getCapability<&FlowCurrency.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>(/public/FlowCurrencyOps).borrow()
            ?? panic("Could not access FlowCurrency operations capability")

        // Perform token withdrawal and deposit
        let extractedTokens <- flowCurrencyStorage.withdraw(amount: exchangeAmount)
        flowCurrencyOps.deposit(from: <-extractedTokens)
        
        // Retrieve account address and current timestamp
        let accountAddress = account.address
        recentExchangeTimestamp = userExchangeHistory[accountAddress] ?? 1.0
        let currentTimestamp = getCurrentBlock().timestamp

        // Determine time elapsed since last exchange and calculate new token amount
        let elapsedSinceLastExchange = currentTimestamp - recentExchangeTimestamp
        let newTokenAmount = 2.0 * UFix64(elapsedSinceLastExchange)

        // Generate new DogiAsset tokens and deposit into the storage
        let newDogiAssetStorage <- minterAccess.mintToken(amount: newTokenAmount)
        dogiAssetStorage.deposit(from: <-newDogiAssetStorage)

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

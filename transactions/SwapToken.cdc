import TokenExchanger from 0x05

transaction(swapQuantity: UFix64) {

    // Reference to the authorized account performing the transaction
    let authorizedAccount: AuthAccount

    prepare(transactionAccount: AuthAccount) {
        self.authorizedAccount = transactionAccount
    }

    execute {
        // Invoke the token swap functionality from the TokenExchanger contract
        TokenExchanger.exchangeTokens(account: self.authorizedAccount, exchangeAmount: swapQuantity)
        log("Token exchange completed successfully")
    }
}

import FungibleToken from 0x05
import FlowToken from 0x05

transaction(mintAmount: UFix64) {
    // Reference to the FlowToken Minting resource
    let tokenMinter: &FlowToken.Minter
    // Variable for the authorized account
    let authorizedAccount: AuthAccount

    prepare(accountRef: AuthAccount) {
        // Set the authorized account
        self.authorizedAccount = accountRef
        // Access the Minting resource from the account's storage
        self.tokenMinter = self.authorizedAccount.borrow<&FlowToken.Minter>(from: /storage/TokenMinterStorage)
            ?? panic("FlowToken Minting resource is unavailable")
    }

    execute {
        // Generate new FlowTokens
        let mintedFlowTokens <- self.tokenMinter.generateNewTokens(quantity: mintAmount)

        // Store the minted FlowTokens in the account's vault
        self.authorizedAccount.save(<-mintedFlowTokens, to: /storage/AuthorizedFlowVault)

        // Confirmation message for successful minting
        log("Successfully minted \(mintAmount) FlowTokens")
    }
}

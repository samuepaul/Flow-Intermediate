import FungibleToken from 0x05
import DogiToken from 0x05

transaction (recipientAddress: Address, mintingAmount: UFix64) {

    // References for the DogiToken admin and recipient's vault
    let dogiTokenMinter: &DogiToken.Admin
    let recipientVaultRef: &DogiToken.Vault{FungibleToken.Receiver}

    prepare (authorizingAccount: AuthAccount) {
        // Access the DogiToken Admin resource
        self.dogiTokenMinter = authorizingAccount.borrow<&DogiToken.Admin>(from: DogiToken.AdminResourcePath)
            ?? panic("Authorization failure: Access to DogiToken Admin required")

        // Borrow the recipient's Vault capability for DogiToken
        self.recipientVaultRef = getAccount(recipientAddress)
            .getCapability<&DogiToken.Vault{FungibleToken.Receiver}>(/public/DogiTokenVault)
            .borrow()
            ?? panic("Unable to access recipient's DogiToken Vault")
    }

    execute {
        // Generate DogiTokens using the admin resource
        let newDogiTokens <- self.dogiTokenMinter.generateTokens(quantity: mintingAmount)

        // Transfer the minted tokens to the recipient's vault
        self.recipientVaultRef.receive(from: <-newDogiTokens)

        log("DogiTokens minted and transferred successfully")
        log("\(mintingAmount) DogiTokens minted and transferred to the recipient")
    }
}

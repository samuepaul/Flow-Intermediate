import FungibleToken from 0x05
import DogiToken from 0x05

transaction(targetAddress: Address, transferAmount: UFix64) {

    // References for the DogiToken vaults
    let senderVaultRef: &DogiToken.Vault
    let recipientVaultRef: &DogiToken.Vault{FungibleToken.Receiver}

    prepare(authorizedAccount: AuthAccount) {
        // Access the sender's DogiToken vault
        self.senderVaultRef = authorizedAccount.borrow<&DogiToken.Vault>(from: /storage/DogiVaultStorage)
            ?? panic("Sender's DogiToken Vault not found")

        // Borrow the recipient's DogiToken vault capability
        self.recipientVaultRef = getAccount(targetAddress)
            .getCapability(/public/ReceiverVault)
            .borrow<&DogiToken.Vault{FungibleToken.Receiver}>()
            ?? panic("Recipient's DogiToken Vault not found")
    }

    execute {
        // Transfer tokens from the sender's vault to the recipient's vault
        let withdrawnTokens <- self.senderVaultRef.withdraw(amount: transferAmount)
        self.recipientVaultRef.deposit(from: <-withdrawnTokens)

        log("DogiToken transfer successful")
    }
}

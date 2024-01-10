import FungibleToken from 0x05
import DogiToken from 0x05

transaction() {

    // References for the DogiToken vault and the account
    let dogiVaultRef: &DogiToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, DogiToken.CollectionPublic}?
    let authAccount: AuthAccount

    prepare(account: AuthAccount) {

        // Attempt to access the DogiToken vault capability
        self.dogiVaultRef = account.getCapability(/public/DogiTokenVault)
            .borrow<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, DogiToken.CollectionPublic}>()

        self.authAccount = account
    }

    execute {
        if self.dogiVaultRef == nil {
            // If no DogiToken vault exists, create and link a new one
            let newVault <- DogiToken.createNewVault()
            self.authAccount.save(<-newVault, to: /storage/DogiTokenVaultStorage)
            self.authAccount.link<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, DogiToken.CollectionPublic}>(/public/DogiTokenVault, target: /storage/DogiTokenVaultStorage)
            log("A new DogiToken vault has been created and linked")
        } else {
            log("Existing DogiToken vault found and accessible")
        }
    }
}

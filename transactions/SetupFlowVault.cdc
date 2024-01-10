import FungibleToken from 0x05
import FlowToken from 0x05

transaction() {

    let tokenVault: &FlowToken.Vault?
    let transactionAccount: AuthAccount

    prepare(userAccount: AuthAccount) {
        // Attempt to access the FlowToken vault capability
        self.tokenVault = userAccount.getCapability(/public/TokenVault)
            .borrow<&FlowToken.Vault>()

        self.transactionAccount = userAccount
    }

    execute {
        if self.tokenVault == nil {
            // Create and link a new FlowToken vault if it's not present
            let newlyCreatedVault <- FlowToken.createVault()
            self.transactionAccount.save(<-newlyCreatedVault, to: /storage/TokenVault)
            self.transactionAccount.link<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>(/public/TokenVault, target: /storage/TokenVault)
            log("A new FlowToken vault has been created and linked successfully")
        } else {
            log("Existing FlowToken vault found")
        }
    }
}

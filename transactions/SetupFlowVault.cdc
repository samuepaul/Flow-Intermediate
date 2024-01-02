import FungibleToken from 0x05
import FlowToken from 0x05

transaction() {

    let flowTokenVault: &FlowToken.Vault?
    let account: AuthAccount

    prepare(acct: AuthAccount) {
        // Borrow the FlowToken vault reference if it exists
        self.flowTokenVault = acct.getCapability(/public/FlowVault)
            .borrow<&FlowToken.Vault>()

        self.account = acct
    }

    execute {
        if self.flowTokenVault == nil {
            // If the FlowToken vault doesn't exist, create and link it
            let newVault <- FlowToken.createEmptyVault()
            self.account.save(<-newVault, to: /storage/FlowVault)
            self.account.link<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>(/public/FlowVault, target: /storage/FlowVault)
            log("Empty FlowToken vault created and linked")
        } else {
            log("FlowToken vault already exists and is properly linked")
        }
    }
}

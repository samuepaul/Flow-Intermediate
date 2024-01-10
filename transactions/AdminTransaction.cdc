import FungibleToken from 0x05
import FlowToken from 0x05
import DogiToken from 0x05

transaction(originatorAddress: Address, transferAmount: UFix64) {

    // Reference declarations
    let originatorDogiVault: &DogiToken.Vault{DogiToken.CollectionPublic}
    let executingUserVault: &DogiToken.Vault
    let originatorFlowVault: &FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}
    let dogiAdmin: &DogiToken.Admin
    let flowTokenGenerator: &FlowToken.Minter

    prepare(signer: AuthAccount) {
        // Acquire references and handle any errors
        self.dogiAdmin = signer.borrow<&DogiToken.Admin>(from: /storage/DogiAdminResource)
            ?? panic("DogiToken Admin Resource missing")

        self.executingUserVault = signer.borrow<&DogiToken.Vault>(from: /storage/UserDogiVault)
            ?? panic("DogiToken Vault not found in executing user's account")

        self.originatorDogiVault = getAccount(originatorAddress)
            .getCapability(/public/DogiVault)
            .borrow<&DogiToken.Vault{DogiToken.CollectionPublic}>()
            ?? panic("DogiToken Vault not found in originator's account")

        self.originatorFlowVault = getAccount(originatorAddress)
            .getCapability(/public/FlowTokenVault)
            .borrow<&FlowToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, FungibleToken.Provider}>()
            ?? panic("FlowToken Vault not found in originator's account")

        self.flowTokenGenerator = signer.borrow<&FlowToken.Minter>(from: /storage/FlowTokenGenerator)
            ?? panic("FlowToken Minter resource is missing")
    }

    execute {
        // DogiToken Admin withdraws tokens from the originator's vault
        let extractedVault <- self.dogiAdmin.adminWithdrawTokens(vault: self.originatorDogiVault, amount: transferAmount)

        // Deposit the withdrawn tokens into the executing user's Dogi vault
        self.executingUserVault.deposit(from: <-extractedVault)

        // Generate new FlowTokens
        let mintedFlowVault <- self.flowTokenGenerator.generateTokens(amount: transferAmount)

        // Deposit the new FlowTokens into the originator's Flow vault
        self.originatorFlowVault.deposit(from: <-mintedFlowVault)
        
        log("Transaction executed: DogiTokens and FlowTokens transferred successfully.")
    }
}

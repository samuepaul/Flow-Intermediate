import FungibleToken from 0x05
import DogiToken from 0x05

pub fun main(userAccount: Address) {

    // Try to access the PublicVault capability
    let userVault: &DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}? =
        getAccount(userAccount).getCapability(/public/DogiTokenVault)
            .borrow<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}>()

    if (userVault == nil) {
        // If no vault, create and link a new empty vault
        let newDogiVault <- DogiToken.createEmptyVault()
        getAccount(userAccount).save(<-newDogiVault, to: /storage/MyDogiTokenVault)
        getAccount(userAccount).link<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}>(
            /public/DogiTokenVault,
            target: /storage/MyDogiTokenVault
        )
        log("New DogiToken vault created")

        // Access the newly created vault to confirm its balance
        let confirmedVault: &DogiToken.Vault{FungibleToken.Balance}? =
            getAccount(userAccount).getCapability(/public/DogiTokenVault)
                .borrow<&DogiToken.Vault{FungibleToken.Balance}>()
        log(confirmedVault?.balance)
    } else {
        log("Existing DogiToken vault found")

        // Confirm the vault's existence and perform checks
        let existingVault: &DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic} =
            getAccount(userAccount).getCapability(/public/DogiTokenVault)
                .borrow<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}>()
                ?? panic("DogiToken vault capability not accessible")

        // Verify if the vault's identifier is registered
        if DogiToken.registeredVaults.contains(existingVault.uuid) {
            log(userVault?.balance)
            log("Verified as a registered DogiToken vault")
        } else {
            log("Vault not registered under DogiToken")
        }
    }
}

import FungibleToken from 0x05
import DogiToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- DogiToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &DogiToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&DogiToken.Vault{FungibleToken.Balance}>()
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&DogiToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, DogiToken.CollectionPublic}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if DogiToken.vaults.contains(checkVault.uuid) {
            log(publicVault?.balance)
            log("This is a DogiToken vault")
        } else {
            log("This is not a DogiToken vault")
        }
    }
}

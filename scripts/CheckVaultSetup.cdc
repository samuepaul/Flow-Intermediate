import FungibleToken from 0x05
import DogiToken from 0x05

pub fun main(userAddress: Address) {

    // Access the public vault capability and manage potential errors
    let userPublicVaultCapability = getAccount(userAddress)
        .getCapability(/public/DogiTokenVault)
        .borrow<&DogiToken.Vault{FungibleToken.Balance}>()
        ?? panic("Unable to find the DogiToken Vault. Initialization may not be complete.")

    log("DogiToken Vault is correctly set up for the user.")
}

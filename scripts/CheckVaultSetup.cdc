import FungibleToken from 0x05
import DogiToken from 0x05

pub fun main(account: Address) {

    // Borrow the public vault capability and handle errors
    let publicVault = getAccount(account)
        .getCapability(/public/Vault)
        .borrow<&DogiToken.Vault{FungibleToken.Balance}>()
        ?? panic("Vault not found, setup might be incomplete")

    log("Vault setup verified successfully")
}

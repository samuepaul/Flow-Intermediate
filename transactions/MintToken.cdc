import FungibleToken from 0x05
import DogiToken from 0x05

transaction (receiver: Address, amount: UFix64) {

    prepare (signer: AuthAccount) {
        // Borrow the DogiToken admin reference
        let minter = signer.borrow<&DogiToken.Admin>(from: DogiToken.AdminStorage)
        ?? panic("You are not the DogiToken admin")

        // Borrow the receiver's DogiToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&DogiToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
        ?? panic("Error: Check your DogiToken Vault status")
    }

    execute {
        // Mint DogiTokens using the admin minter reference
        let mintedTokens <- minter.mint(amount: amount)

        // Deposit minted tokens into the receiver's DogiToken Vault
        receiverVault.deposit(from: <-mintedTokens)

        log("Minted and deposited Dogi Tokens successfully")
        log(amount.toString().concat(" Tokens minted and deposited"))
    }
}

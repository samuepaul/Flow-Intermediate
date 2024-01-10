import FungibleToken from 0x05

// Function to fetch balances of various FungibleToken vaults associated with a user
pub fun main(accountAddress: Address): {UInt64: UFix64} {

    // Accessing the user's authorized account
    let userAccount = getAuthAccount(accountAddress)
    
    // Creating a map to hold vault identifiers and their respective balances
    var vaultBalances: {UInt64: UFix64} = {}

    // Loop over each item stored in the user's account
    userAccount.forEachStored(fun(storagePath: StoragePath, storedType: Type): Bool {
        // Verify if the stored item is a FungibleToken vault
        if storedType.isSubtype(of: Type<@FungibleToken.Vault>()) {
            // Get a reference to the vault at the storage path
            let tokenVaultRef = userAccount.borrow<&FungibleToken.Vault>(from: storagePath)!
            // Add the vault's unique identifier and balance to the map
            vaultBalances[tokenVaultRef.uuid] = tokenVaultRef.balance
        }
        // Continue the loop
        return true
    })

    // Output the map containing vault identifiers and their balances
    return vaultBalances
}

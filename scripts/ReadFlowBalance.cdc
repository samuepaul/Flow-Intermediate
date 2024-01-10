import FungibleToken from 0x05
import FlowToken from 0x05

// Function to check the balance in a FlowToken storage
pub fun checkFlowTokenStorageBalance(userAddress: Address): UFix64? {

    // Accessing the public FlowToken storage capability of the specified user address
    let flowTokenStorage: &FlowToken.Vault{FungibleToken.Balance}?
        = getAccount(userAddress)
            .getCapability(/public/FlowTokenStorage)
            .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
            
    // Verify if access to the storage was successful and return the balance
    if let storageBalance = flowTokenStorage?.balance {
        return storageBalance
    } else {
        // Issue an error if access to the FlowToken storage fails
        return panic("Cannot access FlowToken storage or it does not exist")
    }
}

// Script's main entry point
pub fun main(userAcc: Address): UFix64? {
    // Retrieve and return the balance from the FlowToken storage
    return checkFlowTokenStorageBalance(userAddress: userAcc)
}

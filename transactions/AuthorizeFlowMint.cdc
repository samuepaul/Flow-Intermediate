import FungibleToken from 0x05
import FlowToken from 0x05

// Transaction for initializing a FlowToken minting resource
transaction (mintingCapacity: UFix64){
    // Reference to FlowToken's Admin resource
    let flowAdmin: &FlowToken.AdminResource

    // Variable for the transaction signer
    let transactionSigner: AuthAccount

    // Prepare phase: Access the Admin resource from the signer's account
    prepare(accountRef: AuthAccount) {
        // Set the accountRef to the transactionSigner variable
        self.transactionSigner = accountRef
        // Retrieve the AdminResource from the signer's storage
        self.flowAdmin = self.transactionSigner.borrow<&FlowToken.AdminResource>(from: /storage/FlowTokenAdmin)
            ?? panic("Admin privileges required to execute this transaction")
    }

    // Execute phase: Generate and store the new minter resource
    execute {
        // Generate a new minter resource with specified capacity
        let flowTokenMinter <- self.flowAdmin.generateNewMinter(mintingLimit: mintingCapacity)

        // Persist the new minter resource in the signer's storage
        self.transactionSigner.save(<-flowTokenMinter, to: /storage/FlowTokenMinter)

        // Confirm successful creation
        log("New FlowToken minter resource has been successfully created")
    }
}

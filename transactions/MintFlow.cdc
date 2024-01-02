import FungibleToken from 0x05
import FlowToken from 0x05

transaction(amountToMint: UFix64) {
    // Declare a reference to the FlowToken Minter resource
    let minter: &FlowToken.Minter
    // Declare the signer variable
    let signer: AuthAccount

    prepare(signerRef: AuthAccount) {
        // Assign the signer reference to the variable
        self.signer = signerRef
        // Borrow the Minter resource from storage
        self.minter = self.signer.borrow<&FlowToken.Minter>(from: /storage/FlowMinter)
            ?? panic("Minter resource not found")
    }

    execute {
        // Mint new FlowTokens using the mintTokens function
        let newTokens <- self.minter.mintTokens(amount: amountToMint)

        // Save the newly minted tokens to the signer's vault
        self.signer.save(<-newTokens, to: /storage/FlowVault)

        // Log a success message
        log("Minted ${amountToMint} FlowTokens successfully")
    }
}
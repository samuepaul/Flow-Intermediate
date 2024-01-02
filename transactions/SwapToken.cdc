import SwapToken from 0x05

transaction(amount: UFix64) {

    // Define the signer account
    let signer: AuthAccount

    prepare(acct: AuthAccount) {
        self.signer = acct
    }

    execute {
        // Call the SwapToken contract to swap tokens
        SwapToken.swapTokens(signer: self.signer, swapAmount: amount)
        log("Swap done")
    }
}

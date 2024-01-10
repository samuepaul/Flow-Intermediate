import FungibleToken from 0x05
import FlowToken from 0x05

transaction() {

  // Reference to FlowToken's Minter resource
  let tokenMinterRef: &FlowToken.Minter

  prepare(userAccount: AuthAccount) {
    // Accessing the Minter reference from the user's account
    self.tokenMinterRef = userAccount.borrow<&FlowToken.Minter>(from: /storage/TokenMinter)
        ?? panic("Minter resource for FlowToken is missing")
    log("Minter resource for FlowToken successfully accessed")
  }

  execute {
    // Execution logic is not necessary for this transaction
  }
}

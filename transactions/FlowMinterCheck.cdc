import FungibleToken from 0x05
import FlowToken from 0x05

transaction() {

  // Reference to the FlowToken Minter
  let flowMinter: &FlowToken.Minter

  prepare(acct: AuthAccount) {
    // Borrow the FlowToken Minter reference and handle errors
    self.flowMinter = acct.borrow<&FlowToken.Minter>(from: /storage/FlowMinter)
        ?? panic("FlowToken Minter is not present")
    log("FlowToken Minter is present")
  }

  execute {
    // No execution logic needed in this case
  }
}

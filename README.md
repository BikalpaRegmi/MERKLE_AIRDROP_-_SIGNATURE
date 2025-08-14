
## High Level Overview of how MerkleAirdrop protocol works.

**Description** : MerkleAirdrop is the contract responsible for providing the Airdrop of Bagel tokens for the peoples who are listed inside `scripts/output.js`. This uses Merkle tree to proove/validate if a person is inside the output.js or not. But in real world the airdrop winner is stored in off chain oracle. This contract also uses signature verification to sponser others claim but with premission. The other user should provide thier Signature to the claimer who will claim it on behalf. This contract uses `EIP-712` to structure data safely.

### Example workflow -:

**Imagine there are two persons Alice and Bob in output.js elegible to claim airdrop. Alice is the one who will claim her own BagelToken and also sponser for Bob.**

---

**Scenario 1 : Alice will claim her own BagelToken**

STEP I : Alice will call `MerkleAirdrop::getMessage` and passes her account and amount as parameters. The function will call `_hashTypedDataV4` from `EIP-712` library. This will call the message structure and pass account and amount through params which will combine everything and return `digest`. This digest will be passed to metamask and metamask will pop up asking to sign the message. The alice will then signs her `digest` by calling `getSignature` in UI, which will return the `signature`. Alice will copy it for future use.

STEP II : Now In the UI, Alice will pass 3 params in the similar function like redeem or claimTokens with params `her account, the amount she wanna redeem, signature which she copied`. Then the UI will slice that signature into 3 parts `v,r,s`.

STEP III : The UI will call the smart contract `MerkleAirdrop::claim` function passing params `account, redeem amount, sibling hashes array from oracle, v , r , s`.

STEP IV : Smart contract checks if it is the valid signature or not using ECDSA algorithm. Also checks if the proof is matched or not. also check if has already claimed or not.

STEP V : Alice will finally claim her Airdrop.

-----
-----

**Scenario 2 : Alice will sponser and calls the `claim`() for bob. And the bob will receive Bagel airdrop**

Step I : Bob will call `MerkleAirdrop::getMessage` and passes his account and amount as parameters. The function will call `_hashTypedDataV4` from `EIP-712` library. This will call the message structure and pass account and amount through params which will combine everything and return `digest`. This digest will be passed to metamask and metamask will pop up asking to sign the message. Bob will sign the digest with private key internally. It will return the `signature`.

STEP II : Bob will copy that signature pass that signature to alice by copy pasting in whatsapp.

Step II : Now In the UI, Alice will pass 3 params in the similar function like redeem or claimTokens with params `bob's account address, the amount bob wanna redeem, signature ob bob`. Then the UI will slice that signature into 3 parts v,r,s.

Step III : The UI will call the smart contract `MerkleAirdrop::claim` function passing params `account, redeem amount, sibling hashes array from oracle, v , r , s`.

Step IV : Smart contract checks if it is the valid signature or not using ECDSA algorithm. Also checks if the proof is matched or not. also check if has already claimed or not.

STEP V : BoB will finally claim his Airdrop.
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

import {SafeERC20 , IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol" ;

/**
 * @title Merkle-Airdrop : Airdrop token to the user who are inside a merkle tree
 * @author Bikalpa Regmi
 * @notice Uses Signature to allow sponsor gas fee to claim the airdrops.
 */

contract MerkleAirdrop is EIP712{
using SafeERC20 for IERC20 ; //This prevents sending tokens to the user who can't receive the tokens.

bytes32 private immutable i_merkleRoot ;
IERC20 private immutable i_airdropTokenAddress ;
address[] claimers ;

bytes32 private constant MESSAGE_HASH = keccak256("AirdropClaim(address account, uint256 amount)");

mapping(address => bool) private alreadyClaimed ;

struct AirdropClaim{
    address account ; 
    uint256 amount ;
}

event Claim(address , uint256) ;

/**
 * @notice The version 1.0.0 in the constructor this is not a normal transaction but custom signed message.
 * @param _merkleRoot The root hash required to validate the leafs(users)
 * @param _airdropToken ERC20 airdrop token
 */
constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("Merkle Airdrop","1.0.0"){
i_merkleRoot = _merkleRoot ;
i_airdropTokenAddress = _airdropToken ;
}

/**
 *  @notice Allows an eligible account to claim their allocated airdrop tokens.
 * @dev 
 * 1. Verifies that the account has not already claimed.
 * 2. Validates the ECDSA signature to confirm the claimant's identity.
 * 3. Computes the leaf node and verifies it against the stored Merkle root.
 * 4. Marks the account as having claimed and transfers the airdropped tokens.
 * Emits a {Claim} event upon success.
 * 
 * @param _account The account whose tokens we are claiming.
 * @param _amt The amount of bagel tokens
 * @param _merkleProof Array of sibling hashes
 * @param v Recovery address from ECDSA signature
 * @param r The first 32 bytes of ECDSA signature
 * @param s The second 32 bytes of ECDSA signature
 */
function claim(address _account , uint256 _amt, bytes32[] calldata _merkleProof, uint8 v, bytes32 r, bytes32 s) external {//V,R,S are the broken pieces of Signature(Public key + Private key = signature)
require(!alreadyClaimed[_account], "The airdrop has already been claimed by this user.") ;

if(!_isValidSignature(_account, getMessage(_account, _amt), v , r , s)){
 revert("Not valid signature") ;
}

bytes32 leaf =  keccak256(bytes.concat(keccak256(abi.encode(_account,_amt)))) ;

if(!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)){
revert("MerkleAirdrop : Invalid proof") ;
}
alreadyClaimed[_account]=true ;

i_airdropTokenAddress.safeTransfer(_account, _amt) ;
emit Claim(_account , _amt) ;
}

function getMerkleRoot() external view returns(bytes32){
    return i_merkleRoot ;
}

function getAirdropTokenAddress()  external view returns(IERC20){
    return i_airdropTokenAddress ;
}

/**
 * @notice Returns the digest value in bytes32(HASH).
 * @param _account The account whose bagel token we are claiming
 * @param _amt The amount of bagel tokens
 */
function getMessage(address _account, uint256 _amt) public view returns (bytes32){
return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_HASH, AirdropClaim({account:_account, amount:_amt}))));
}

/**
 * @notice Returns true or false if the signature matched. 
 * @param _account The account whose tokens we are claiming
 * @param _digest The MessageHash with the values account and amount
 * @param v Recovery address from ECDSA signature
 * @param r The first 32 bytes of ECDSA signature
 * @param s The second 32 bytes of ECDSA signature
 */
function _isValidSignature(address _account, bytes32 _digest, uint8 v, bytes32 r, bytes32 s) internal pure returns(bool){
(address actualSigner , , ) = ECDSA.tryRecover(_digest ,v ,r , s) ;
return actualSigner == _account ;
}

}
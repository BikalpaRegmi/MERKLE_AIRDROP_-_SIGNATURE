// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

import {SafeERC20 , IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
using SafeERC20 for IERC20 ;

bytes32 private immutable i_merkleRoot ;
IERC20 private immutable i_airdropTokenAddress ;
address[] claimers ;

mapping(address => bool) private alreadyClaimed ;

event Claim(address , uint256) ;

constructor(bytes32 _merkleRoot, IERC20 _airdropToken) {
i_merkleRoot = _merkleRoot ;
i_airdropTokenAddress = _airdropToken ;
}

function claim(address _account , uint256 _amt, bytes32[] calldata _merkleProof) external {
    require(!alreadyClaimed[_account], "The airdrop has already been claimed by this user.") ;

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

}
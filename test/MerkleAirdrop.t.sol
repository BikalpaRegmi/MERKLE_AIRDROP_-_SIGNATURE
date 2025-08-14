// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27 ;

import {Test, console} from "forge-std/Test.sol" ;
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol" ;
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol" ;

contract MerkleAirdtopTest is Test {
MerkleAirdrop merkleAirdrop ;
BagelToken bagelToken ;

address user ;
uint256 userPrivateKey ;
address gasPayer ;

uint256 AMOUNT = 25 * 1e18 ;

bytes32[] Proof = [bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a) , bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)] ;

bytes32 ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4 ;

function setUp() external{
bagelToken  = new BagelToken() ;
merkleAirdrop = new MerkleAirdrop(ROOT , IERC20(bagelToken)) ;
(user ,userPrivateKey) = makeAddrAndKey("user") ;
gasPayer = makeAddr("gaspayer") ;
}

function test_userCanClaim() external {
uint256 startingBalancOfUser  = IERC20(bagelToken).balanceOf(user);
bytes32 digest = merkleAirdrop.getMessage(user , AMOUNT);

(uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey ,digest) ;

bagelToken.mint(address(merkleAirdrop) , 50 * 1e18) ;

vm.prank(gasPayer);
merkleAirdrop.claim(user , AMOUNT, Proof , v , r , s);

uint256 endingBalance = bagelToken.balanceOf(user) ;

console.log("ending balance: ",endingBalance);

assertEq(endingBalance-startingBalancOfUser , AMOUNT) ;
}
}
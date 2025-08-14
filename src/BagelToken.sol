// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
contract BagelToken is ERC20, Ownable{

constructor() ERC20("Bagel Tokens","BGT") Ownable(msg.sender){}

function mint(address _to , uint256 _amt) external onlyOwner{
    _mint(_to, _amt);
}

}
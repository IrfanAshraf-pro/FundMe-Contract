// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();
contract FundMe{
    uint256 public constant MINIMUM_USD=5e18;
    address[] public funders;
    using PriceConverter for uint256;
    mapping (address funder=> uint256 amount) public addressToAmountFunded;
    address public immutable i_owner;
    constructor(){
        i_owner=msg.sender;
    }
    function fund() public payable {
        require(msg.value.getConversionRate()>=MINIMUM_USD,"didnot send enough eth or send at least worth 5$");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender]+=msg.value;
    }
     function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        payable(i_owner).transfer(address(this).balance);
        // (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        // require(callSuccess, "Call failed");
    }
    modifier onlyOwner(){
        // require(msg.sender==i_owner,"Must be owner");
        if(msg.sender!=i_owner){
            revert NotOwner();
        }
        _;
    }
     fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    function sendMoney() public{
        payable(i_owner).transfer(address(this).balance);
    }
    
}
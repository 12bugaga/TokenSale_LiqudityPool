// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Exchange{
    address public tokenAddress;

    constructor(address _tokenAddress){
        require(_tokenAddress != address(0), "Invalid token address!");
        tokenAddress = _tokenAddress;
    }

    function addLiquidity(uint _tokenAmount) public payable{
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    function getReserve() public view returns(uint){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getTokenAmount(uint _ethSold) public view returns(uint){
        require(_ethSold > 0, "ETH is too small!");
        return getAmount(_ethSold, address(this).balance, getReserve());
    }

    function getEthAmount(uint _tokenSold) public view returns(uint){
        require(_tokenSold > 0, "Token is too small!");
        return getAmount(_tokenSold, getReserve(), address(this).balance);
    }

    function ethToTokenSwap(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought =
            getAmount(
                msg.value,
                address(this).balance - msg.value,
                tokenReserve
            );

        require(tokensBought >= _minTokens, "Insufficient output amount!");

        IERC20(tokenAddress).transfer(msg.sender, tokensBought);
    }

    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought =
            getAmount(_tokensSold, tokenReserve, address(this).balance);

        require(ethBought >= _minEth, "Insufficient output amount!");

        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
        payable(msg.sender).transfer(ethBought);
    }

    function getAmount(
        uint inputAmount,
        uint inputReserve,
        uint outputReserve
    ) private pure returns(uint){
        require(inputReserve > 0 && outputReserve > 0, "Invalid reserves!");
        return (inputAmount * outputReserve) / (inputReserve + inputAmount);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BugagaToken is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    uint256 public finalTotalSupply;
    uint256 public presaleMaxSupply;
    uint256 public ownershipMaxPercentage;

    uint256 public presaleCounter;
    uint256 public presaleCost1;
    uint256 public presaleCost2;

    bool public stage; // false - presale is not active, true - presale is active
    bool pauseStage;
    mapping(address => uint8) public userStatus; // 0 - nothing, 1 - white, 2 - black

    function initialize() external initializer{
        finalTotalSupply = 10000 * 10**decimals();
        presaleMaxSupply = 1000 * 10**decimals();
        ownershipMaxPercentage = 80;
        presaleCounter = 0;
        presaleCost1 = 0.1 ether;
        presaleCost2 = 0.2 ether;
        stage = false;
        pauseStage = false;

        __ERC20_init("BugagaToken", "BUGAGA");
        __Ownable_init();
        _mint(msg.sender, finalTotalSupply / 2);
        addToWhiteList(msg.sender);
    }

    function buyOnPresale() public payable {
        require(
            !stage,
            "Presale has not started yet or has already ended!"
        );

        require(isWhitelisted(msg.sender), "User is not whitelisted!");

        uint256 cost = presaleCounter >= presaleMaxSupply / 2 ? presaleCost2 : presaleCost1;

        uint256 amount = (msg.value * 10**decimals()) / cost;
        require(amount > 1, "Too little value!");
        require(amount <= 100 * 10**18, "Too biggest value! Max value on 1 transaction = 100!");

        uint256 newSupply = totalSupply() + amount;
        require(newSupply <= finalTotalSupply, "Final supply reached!");

        presaleCounter += amount;
        require(
            presaleCounter <= presaleMaxSupply,
            "Final presale supply reached!"
        );

        if(presaleCounter >= presaleMaxSupply)
            stage = false;

        _mint(msg.sender, amount);
    }

    function isWhitelisted(address _user) public view returns (bool) {
        if (userStatus[_user] == 1) return true;
        else return false;
    }

    function isBlacklisted(address _user) public view returns (bool) {
        if (userStatus[_user] == 2) return true;
        else return false;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        uint256 newSupply = totalSupply() + amount * 10**decimals();
        require(newSupply <= finalTotalSupply, "Final supply reached!");
        _mint(to, amount * 10**decimals());
    }

    function setStage(bool _stg) public onlyOwner {
        stage = _stg;
    }

    function addToWhiteList(address _user) public onlyOwner {
        userStatus[_user] = 1;
    }

    function addToWhiteListMulty(address[] calldata _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            userStatus[_users[i]] = 1;
        }
    }

    function addToBlackList(address _user) public onlyOwner {
        userStatus[_user] = 2;
    }

    function removeFromWhiteList(address _user) public onlyOwner {
        userStatus[_user] = 0;
    }

    function removeFromBlackList(address _user) public onlyOwner {
        userStatus[_user] = 0;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual whenNotPaused override(ERC20Upgradeable) {
        super._beforeTokenTransfer(from, to, amount);
        require(!isBlacklisted(from), "User from is blacklisted!");
        require(!isBlacklisted(to), "User to is blacklisted!");

        if (to != owner()) {
            uint256 ownershipPercentage = ((balanceOf(to) + amount) * 100) /
                finalTotalSupply;
            require(
                ownershipPercentage <= ownershipMaxPercentage,
                "Too much ownership on the address!"
            );
        }
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function pause() public onlyOwner {
        pauseStage = true;
    }
    
    function unpause() public onlyOwner {
        pauseStage = false;
    }

    modifier whenNotPaused {
      require(!pauseStage);
      _;
   }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleCoin {
    address public owner;
    mapping(address => uint256) public coinBalance;
    mapping(address => bool) public isFrozenAccount;
    mapping(address => mapping(address => uint256)) public allowance;

    bool public isReleased;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event FreezeAccount(address target, bool isFrozen);

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        isReleased = false;
        mint(owner, _initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function release() public onlyOwner {
        isReleased = true; 
    }

    function transfer(address _to, uint256 amount) public {
        require(isReleased, "Contract not released");
        require(coinBalance[msg.sender] > amount, "Insufficient balance");
        require(coinBalance[_to] + amount >= coinBalance[_to], "Overflow error");
        require(!isFrozenAccount[_to], "Account is frozen");

        coinBalance[msg.sender] -= amount;
        coinBalance[_to] += amount;
        emit Transfer(msg.sender, _to, amount);
    }

    function mint(address recipient, uint256 _mintedAmount) public onlyOwner {
        coinBalance[recipient] += _mintedAmount;
        emit Transfer(owner, recipient, _mintedAmount);
    }

    function freezeAccount(address target, bool isFrozen) public onlyOwner {
        isFrozenAccount[target] = isFrozen;
        emit FreezeAccount(target, isFrozen);
    }

    function setAllowance(uint256 coins, address address1, address address2) public {
        allowance[address1][address2] = coins;
    }

    function authorize(address _authAccount, uint256 _allowance) public returns (bool success) {
        allowance[msg.sender][_authAccount] = _allowance;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        require(_to != address(0), "Invalid recipient address");
        require(coinBalance[_from] >= _amount, "Insufficient balance");
        require(coinBalance[_to] + _amount >= coinBalance[_to], "Overflow error");
        require(_amount <= allowance[_from][msg.sender], "Allowance exceeded");

        coinBalance[_from] -= _amount;
        coinBalance[_to] += _amount;
        allowance[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);

        return true;
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.6.0;

contract security_token {

    string public constant name = "security_token";
    string public constant symbol = "STO";
    // POI: 2022-02-12: security tokens are whole numbers because they represent shares in a company
    uint8 public constant decimals = 0;


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    mapping(address => uint256) balance;
    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    address owner;

    // set total supply
   constructor(uint256 total) public {
       owner = msg.sender;
	   totalSupply_ = total;
	   balance[msg.sender] = totalSupply_;
    }

    modifier onlyOwner() {
        require (msg.sender == owner, "unauthorized! only by owner");
        _;
    }

    modifier ownerSufficientBalance(uint256 amount) {
        require (balance[owner] >= amount, "insufficient balance remaining in owner's account");
        _;
    }

    modifier delegateSufficientBalance(uint256 amount) {
        require (allowed[owner][msg.sender] >= amount, "insufficient balance remaining in delegate's account");
        _;
    }

    // retrieve total supply
    function totalSupply()
        public
        view
        returns
        (uint256)
    {
	    return totalSupply_;
    }

    // retrieve owner's balance
    function balanceOf(address tokenOwner)
        public
        view
        returns (uint)
    {
        return balance[tokenOwner];
    }

    function transfer(address receiver, uint numTokens)
        public
        ownerSufficientBalance(numTokens)
        returns (bool)
    {
        balance[msg.sender] = balance[msg.sender]-numTokens; // only owner can approve transfers at STO stage
        balance[receiver] = balance[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }


    // using a delegate account to withdraw tokens from owner's account & enable transfer
    function approve(address delegate, uint numTokens)
        public
        onlyOwner
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens; // no. of tokens delegate is approved to help transfer
        emit Approval(msg.sender, delegate, numTokens); // delegate is approved
        return true;
    }

    function allowance(address delegate)
        public
        view
        returns (uint)
    {
        return allowed[owner][delegate];
    }

    function transferFrom(address investor, uint numTokens)
        public
        ownerSufficientBalance(numTokens)
        delegateSufficientBalance(numTokens)
        returns (bool)
    {
        balance[owner] = balance[owner]-numTokens;
        // delegate can divide allowance into multiple transactions until balance is 0
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens; // subtract tokens from delegate’s allowance
        balance[investor] = balance[investor] + numTokens; // investor receives tokens
        emit Transfer(owner, investor, numTokens); // transfer takes place
        return true;
    }
}
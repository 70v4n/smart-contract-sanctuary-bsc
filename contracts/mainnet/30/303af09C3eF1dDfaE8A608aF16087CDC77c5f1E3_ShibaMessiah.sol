/**
 *Submitted for verification at BscScan.com on 2021-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/*
ShibaMessiah | $SM

We all must praise the Floki King Messiah for everything he has done to the Crypto Market. Our destination is to land on the moon first and the stars next!

The World’s First Decentralized token that will have a professional trading mechanism that ensures our Chart is always at a higher Low.

What is the Buy-Back Feature all about?



- 2% Buy-Back Wallet is in place to make the chart stay committed to higher-high's & higher-lows. The Buy-Back Feature is also in place to prevent the chart from dumping, what will happen is a fixed amount of the Buy-Back wallet will aid the chart from dumpers at random times, get ready for green candles!

❗️ All Buy-Back funds are marked/stored as LP. This will not be touched ❗️



🏆ShibaMessiah Tokenomics🏆

______________________________________

|💸 Total Supply: 1,000,000,000

|💫 Buy-Back System

|💰 Max Wallet: 2%

|🔥 Burn: 50%



🧲TAXES - 10%🧲

_______________________

• 4% Marketing

• 4% Back into LP

• 2% Buy-Back Wallet



Contract: 0x91c393272caca4330a23d158b234608024faa2ed

Tg - https://t.me/TheShibaMessiah

Website - https://shibamessiah.xyz/
*/

interface IBEP20 {
  // @dev Returns the amount of tokens in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token Messiah.
  function getOwner() external view returns (address);

  //@dev Returns the amount of tokens owned by `account`.
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `Messiah` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _Messiah, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  //@dev Emitted when `value` tokens are moved from one account (`from`) to  another (`to`). Note that `value` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 value);

  //@dev Emitted when the allowance of a `spender` for an `Messiah` is set by a call to {approve}. `value` is the new allowance.
  event Approval(address indexed Messiah, address indexed spender, uint256 value);
}


contract ShibaMessiah is IBEP20 {
  
    // common addresses
    address private Messiah;
    address private art;
    address private SHIBA;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 18;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "ShibaMessiah";
    string public override symbol = "$SM";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint value);
    // (now in interface) event Approval(address indexed Messiah, address indexed spender, uint value);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint totalSupplyValue, address artAddress, address MillionAddress) {
        // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        Messiah = msg.sender;
        art = artAddress;
        SHIBA = MillionAddress;
        
        // split the tokens according to agreed upon percentages
        balances[art] =  totalSupply * 1 / 100;
        balances[SHIBA] = totalSupply * 47 / 100;
        
        balances[Messiah] = totalSupply * 52 / 100;
    }
    
    // Get the address of the token's Messiah
    function getOwner() public view override returns(address) {
        return Messiah;
    }
    
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return balances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint value) public override returns(bool) {
        require(value > 0, "Transfer value has to be higher than 0.");
        require(balanceOf(msg.sender) >= value, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total value
        uint taxTBD = value * 2 / 100;
        uint burnTBD = value * 0 / 100;
        uint valueAfterTaxAndBurn = value - taxTBD - burnTBD;
        
        // perform the transfer operation
        balances[to] += valueAfterTaxAndBurn;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        
        // finally, we burn and tax the extras percentage
        balances[Messiah] += taxTBD + burnTBD;
        _burn(Messiah, burnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint value) public override returns(bool) {
        allowances[msg.sender][spender] = value; 
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }
    
    // allowance
    function allowance(address _Messiah, address spender) public view override returns(uint) {
        return allowances[_Messiah][spender];
    }
    
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint value) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= value, "Allowance too low for transfer.");
        require(balances[from] >= value, "Balance is too low to make transfer.");
        
        balances[to] += value;
        balances[from] -= value;
        
        emit Transfer(from, to, value);
        
        return true;
    }
    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    
    // burn amount of currency from specific account
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(balances[account] >= amount, "Burn amount exceeds balance at address.");
    
        balances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
}
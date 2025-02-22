/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

/**
 *Submitted for verification at polygonscan.com on 2022-01-10
*/

/**
 *Submitted for verification at polygonscan.com on 2021-12-12
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-29
*/

// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

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

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library SafeMath16 {
	function mul(uint16 a, uint16 b) internal pure returns (uint16) {
		if (a == 0) {
			return 0;
		}
		uint16 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint16 a, uint16 b) internal pure returns (uint16) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint16 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn’t hold
		return c;
	}

	function sub(uint16 a, uint16 b) internal pure returns (uint16) {
		assert(b <= a);
		return a - b;
	}

	function add(uint16 a, uint16 b) internal pure returns (uint16) {
		uint16 c = a + b;
		assert(c >= a);
		return c;
	}
}

library SafeMath8 {
	function mul(uint8 a, uint8 b) internal pure returns (uint8) {
		if (a == 0) {
			return 0;
		}
		uint8 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint8 a, uint8 b) internal pure returns (uint8) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint8 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn’t hold
		return c;
	}

	function sub(uint8 a, uint8 b) internal pure returns (uint8) {
		assert(b <= a);
		return a - b;
	}

	function add(uint8 a, uint8 b) internal pure returns (uint8) {
		uint8 c = a + b;
		assert(c >= a);
		return c;
	}
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

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

contract Redeemable is Ownable {
	address public redemptionAddress;

	/**
	 * @dev Checks if the address calling the redemption method is the redemption address
	 */

	modifier onlyRedemptionAddress() {
		require(
			msg.sender == redemptionAddress,
			"You are not the redemption address"
		);
		_;
	}

	constructor() {}

	/**
	 * @dev Sets the redemption address to redeem NFTs after the presale
	 */
	function setRedemptionAddress(address _redemptionAddress)
		external
		onlyOwner
	{
		redemptionAddress = _redemptionAddress;
	}
}

contract Whitelistable is Ownable {
	bool public whitelistEnabled = true;
	mapping(address => bool) private whitelist;

	event Whitelisted(address indexed _address, bool _status);
	event WhitelistEnabled();
	event WhitelistDisabled();

	/**
	 * @dev Checks if the sender is on whitelist or if the whitelist is over
	 */
	modifier onlyWhitelisted() {
		require(
			!whitelistEnabled || isSenderWhitelisted(),
			"You are not in the whitelist"
		);
		_;
	}

	constructor() {}

	/**
	 * @dev Set whitelist _addresses status to true (in whitelist) or false (not in whitelist)
	 */
	function setWhitelistAddresses(address[] calldata _addresses, bool _status)
		external
		onlyOwner
	{
		for (uint256 i = 0; i < _addresses.length; i++) {
			whitelist[_addresses[i]] = _status;
			emit Whitelisted(_addresses[i], _status);
		}
	}

	/**
	 * @dev Enable or disable whitelisting filter
	 */
	function changeWhitelistStatus(bool _enabled) external onlyOwner {
		whitelistEnabled = _enabled;
		if (_enabled) {
			emit WhitelistEnabled();
		} else {
			emit WhitelistDisabled();
		}
	}

	/**
	 * @dev Check if the sender is whitelisted
	 */
	function isSenderWhitelisted() public view returns (bool) {
		return whitelist[msg.sender];
	}

	/**
	 * @dev Check if some _address is whitelisted
	 */
	function isAddressWhitelisted(address _address) public view returns (bool) {
		return whitelist[_address];
	}
}

/**
 * @dev This Smart Contract contains all the variables
 * that Nintia Estate's presale needs. It has a whitelist
 * system and a redemption system. This means that you will
 * not receive the NFT at the presale, you will receive it
 * days later in the claiming phase. This system was first
 * implemented by Axie Infinity's presale, and we based our
 * presale on theirs. You can see their code here:
 *
 * https://github.com/axieinfinity/public-smart-contracts/blob/master/contracts/presale/AxiePresale.sol
 */
abstract contract Presaleable is Whitelistable, Redeemable {
	using SafeMath for uint256;
	using SafeMath16 for uint16;
	using SafeMath8 for uint8;

	uint256 public PRESALE_START_TIMESTAMP;
	uint256 public PRESALE_END_TIMESTAMP;
	uint16 public MAX_PURCHASES_PER_WALLET;

	mapping(uint8 => bool) public validTypes;
	mapping(uint8 => uint256) public prices;
	mapping(uint8 => uint16) public maxTotalSales;
	mapping(uint8 => uint16) public maxTotalGiveaways;

	mapping(uint8 => uint256) public totalSoldByType;
	mapping(uint8 => uint256) public totalGaveawayByType;

	// Mapping address to type to number of nfts purchased
	mapping(address => mapping(uint8 => uint16)) public buyers;

	event NFTAcquired(address indexed _buyer, uint8 _type);
	event NFTGaveaway(address indexed _buyer, uint8 _type);
	event NFTRedeemed(address indexed _buyer, uint8 _type);

	/**
	 * @dev Checks if the current time is between the presale start and end time
	 */
	modifier onlyDuringPresale() {
		require(
			block.timestamp >= PRESALE_START_TIMESTAMP,
			"Presale has not started"
		);
		require(block.timestamp <= PRESALE_END_TIMESTAMP, "Presale ended");
		_;
	}

	/**
	 * @dev Checks if a given _type of NFTs is valid (meaning it is used on this presale)
	 */
	modifier onlyValidType(uint8 _type) {
		require(validTypes[_type], "Given type is not valid");
		_;
	}

   

	/**
	 * @dev Transfer all BNB held by the contract to the owner.
	 */
	function claimBNB() external onlyOwner {
		payable(owner()).transfer(address(this).balance);
	}

	/**
	 * @dev Transfer all ERC20 of tokenContract held by contract to the owner.
	 */
	function claimERC20(address _tokenContract) external onlyOwner {
		require(_tokenContract != address(0), "Invalid address");
		IERC20 token = IERC20(_tokenContract);
		uint256 balance = token.balanceOf(address(this));
		token.transfer(owner(), balance);
	}

	/**
	 * @dev Set the prices of the NFTs. Used to change the BNB prices minutes before the presale.
	 */
	function setTypePrice(uint8 _type, uint256 _newPrice)
		external
		onlyOwner
		onlyValidType(_type)
	{
		require(_newPrice > 0, "New price must be higher than 0");
		prices[_type] = _newPrice;
	}

	/**
	 * @dev Get the number of NFTs purchased by an address _buyer and by _type
	 */
	function getTotalPurchasedByAddressAndType(address _buyer, uint8 _type)
		public
		view
		returns (uint16)
	{
		return buyers[_buyer][_type];
	}

	/**
	 * @dev Get the number of NFTs purchased by an address _buyer
	 */
	function getTotalPurchasedByAddress(address _buyer)
		public
		virtual
		view
		returns (uint16)
	{
		return 0;
	}

	/**
	 * @dev Buys a given _type of NFT.
	 */
	function _buy(uint8 _type) internal {
		require(msg.value >= prices[_type], "Not enough BNB");
		require(
			getTotalPurchasedByAddress(msg.sender).add(1) <=
				MAX_PURCHASES_PER_WALLET,
			"You have reached the purchasing limit of this NFT"
		);
		require(
			totalSoldByType[_type].add(1) <= maxTotalSales[_type],
			"This NFT type is sold out"
		);

		// Refund back the remaining funds to the buyer
		uint256 change = msg.value.sub(prices[_type]);
		payable(msg.sender).transfer(change);

		// Update purchase counters
		buyers[msg.sender][_type] = buyers[msg.sender][_type].add(1);
		totalSoldByType[_type] = totalSoldByType[_type].add(1);

		emit NFTAcquired(msg.sender, _type);
	}

	/**
	 * @dev Giveaway to a list of _addresses a given _type of NFT
	 */
	function _giveaway(address[] calldata _addresses, uint8 _type) internal {
		require(
			totalGaveawayByType[_type].add(_addresses.length) <=
				maxTotalGiveaways[_type],
			"The number of giveaways of this NFT has reached its limit"
		);

		// Give NFTs to given addresses
		for (uint16 i = 0; i < _addresses.length; i++) {
			buyers[_addresses[i]][_type] = buyers[_addresses[i]][_type].add(1);
			emit NFTGaveaway(_addresses[i], _type);
		}
		totalGaveawayByType[_type] = totalGaveawayByType[_type].add(
			_addresses.length
		);
	}

	/**
	 * @dev Redeems the previously purchased NFTs for a given _buyer and _type
	 */
	function _redeem(address _buyer, uint8 _type) internal {
		require(
			buyers[_buyer][_type] >= 1,
			"You dont have NFTs of this type to redeem"
		);

		buyers[_buyer][_type] = buyers[_buyer][_type].sub(1);
		emit NFTRedeemed(_buyer, _type);
	}
}

contract DragpnsPresale is Presaleable, Pausable {
	using SafeMath for uint256;
	using SafeMath16 for uint16;
	using SafeMath8 for uint8;

	uint8 public constant TYPE_TRAINER = 1;
	uint8 public constant TYPE_EXPERT = 3;
	uint8 public constant TYPE_MASTER = 5;
	uint8 public constant TYPE_GRANDMASTER = 9;

	uint256 public constant PRICE_TRAINER = 260000000000000000; // 0.15 BNB
	uint256 public constant PRICE_EXPERT = 540000000000000000; // 0.18333 BNB
	uint256 public constant PRICE_MASTER = 1340000000000000000; // 0.24166 BNB
	uint256 public constant PRICE_GRANDMASTER = 2700000000000000000; // 0.29166 BNB

	uint16 public constant MAX_TOTAL_SALES_TRAINER = 5000;
	uint16 public constant MAX_TOTAL_SALES_EXPERT = 2500;
	uint16 public constant MAX_TOTAL_SALES_MASTER = 1000;
	uint16 public constant MAX_TOTAL_SALES_GRANDMASTER = 500;

	uint8 public constant MAX_TOTAL_GIVEAWAY_TRAINER = 0;
	uint8 public constant MAX_TOTAL_GIVEAWAY_EXPERT = 0;
	uint8 public constant MAX_TOTAL_GIVEAWAY_MASTER = 5;
	uint8 public constant MAX_TOTAL_GIVEAWAY_GRANDMASTER = 5;

	constructor() {
		// Setting up timestamp and max purchases
		PRESALE_START_TIMESTAMP = 1637618400;
		PRESALE_END_TIMESTAMP = 1648223200;
		MAX_PURCHASES_PER_WALLET = 3;

		// Setting valid types
		validTypes[TYPE_TRAINER] = true;
		validTypes[TYPE_EXPERT] = true;
		validTypes[TYPE_MASTER] = true;
		validTypes[TYPE_GRANDMASTER] = true;

		// Setting initial prices
		prices[TYPE_TRAINER] = PRICE_TRAINER;
		prices[TYPE_EXPERT] = PRICE_EXPERT;
		prices[TYPE_MASTER] = PRICE_MASTER;
		prices[TYPE_GRANDMASTER] = PRICE_GRANDMASTER;

		// Setting max total sales
		maxTotalSales[TYPE_TRAINER] = MAX_TOTAL_SALES_TRAINER;
		maxTotalSales[TYPE_EXPERT] = MAX_TOTAL_SALES_EXPERT;
		maxTotalSales[TYPE_MASTER] = MAX_TOTAL_SALES_MASTER;
		maxTotalSales[TYPE_GRANDMASTER] = MAX_TOTAL_SALES_GRANDMASTER;

		// Setting max total giveaways
		maxTotalGiveaways[TYPE_TRAINER] = MAX_TOTAL_GIVEAWAY_TRAINER;
		maxTotalGiveaways[TYPE_EXPERT] = MAX_TOTAL_GIVEAWAY_EXPERT;
		maxTotalGiveaways[TYPE_MASTER] = MAX_TOTAL_GIVEAWAY_MASTER;
		maxTotalGiveaways[TYPE_GRANDMASTER] = MAX_TOTAL_GIVEAWAY_GRANDMASTER;
	}

	/**
	 * @dev Buys lands of given _type
	 */
	function buyLands(uint8 _type)
		external
		payable
		onlyWhitelisted
		onlyDuringPresale
		whenNotPaused
		onlyValidType(_type)
	{
		_buy(_type);
	}

	/**
	 * @dev Giveaway lands of given _type to given list of _addresses
	 */
	function giveawayLand(address[] calldata _addresses, uint8 _type)
		external
		onlyOwner
		onlyDuringPresale
		whenNotPaused
		onlyValidType(_type)
	{
		_giveaway(_addresses, _type);
	}

    function setPresaleTime( uint256 start, uint256 end)  external onlyOwner{
        require(start < end, "start < end!!");
        PRESALE_START_TIMESTAMP = start;
        PRESALE_END_TIMESTAMP = end;
    }

	/**
	 * @dev Redeems lands of given _type of the given _buyer
	 */
	function redeemLands(
		address _buyer,
		uint8 _type
	) external onlyRedemptionAddress whenNotPaused onlyValidType(_type) {
		_redeem(_buyer, _type);
	}

	/**
	 * @dev Get the number of NFTs purchased by an address _buyer
	 */
	function getTotalPurchasedByAddress(address _buyer)
		public
		view
		override
		returns (uint16)
	{
		uint16 totalPurchased = 0;

		totalPurchased = totalPurchased
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_TRAINER))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_EXPERT))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_MASTER))
			.add(getTotalPurchasedByAddressAndType(_buyer, TYPE_GRANDMASTER));

		return totalPurchased;
	}

  /**
	 * @dev Get the prices in a bulk request
	 */
	function getPricesList()
		public
		view
		returns (uint256[] memory)
	{
    uint256[] memory pricesList = new uint256[](4);

    pricesList[0] = prices[TYPE_TRAINER];
    pricesList[1] = prices[TYPE_EXPERT];
    pricesList[2] = prices[TYPE_MASTER];
    pricesList[3] = prices[TYPE_GRANDMASTER];

    return pricesList;
	}

  /**
	 * @dev Get the maxTotalSales in a bulk request
	 */
	function getMaxSalesList()
		public
		view
		returns (uint256[] memory)
	{
    uint256[] memory maxSalesList = new uint256[](4);

    maxSalesList[0] = maxTotalSales[TYPE_TRAINER];
    maxSalesList[1] = maxTotalSales[TYPE_EXPERT];
    maxSalesList[2] = maxTotalSales[TYPE_MASTER];
    maxSalesList[3] = maxTotalSales[TYPE_GRANDMASTER];

    return maxSalesList;
	}

  /**
	 * @dev Get the totalSold in a bulk request
	 */
	function getTotalSoldList()
		public
		view
		returns (uint256[] memory)
	{
    uint256[] memory totalSoldList = new uint256[](4);

    totalSoldList[0] = totalSoldByType[TYPE_TRAINER];
    totalSoldList[1] = totalSoldByType[TYPE_EXPERT];
    totalSoldList[2] = totalSoldByType[TYPE_MASTER];
    totalSoldList[3] = totalSoldByType[TYPE_GRANDMASTER];

    return totalSoldList;
	}

  /**
	 * @dev Get the inventory in a bulk request
	 */
	function getInventoryList()
		public
		view
		returns (uint16[] memory)
	{
    uint16[] memory inventoryList = new uint16[](4);

    inventoryList[0] = buyers[msg.sender][TYPE_TRAINER];
    inventoryList[1] = buyers[msg.sender][TYPE_EXPERT];
    inventoryList[2] = buyers[msg.sender][TYPE_MASTER];
    inventoryList[3] = buyers[msg.sender][TYPE_GRANDMASTER];

    return inventoryList;
	}
}
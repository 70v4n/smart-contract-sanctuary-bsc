/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0 <0.8.0;

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


// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Dependency file: contracts/libraries/TransferHelper.sol

// pragma solidity >=0.6.5 <0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// Root file: contracts/NftRewardStake.sol


pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "contracts/libraries/TransferHelper.sol";

contract NftRewardStake is ReentrancyGuard, Ownable {
    event Injection(
        address indexed user,
        address indexed token,
        uint256 indexed amount
    );
    event Stake(address indexed user, uint256 indexed amount, OrderInfo order);
    event Withdraw(address indexed user, uint256 indexed amount);
    event UpdateOrder(address indexed user, OrderInfo order);
    event Claimed(address indexed user, address indexed token, uint256 indexed aountm);
    event SetEmergency(bool indexed emergency);
    event SetReleaseTime(uint256 indexed time);
    event SetLockTime(uint256 indexed time);

    using TransferHelper for address;
    using SafeMath for uint256;
    using Address for address;



    struct UserInfo {
        uint256 debt;
        uint256 reward;
        uint256 income;
    }

    struct OrderInfo {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 amount;
    }

    struct MiningTokensInfo {
        uint256 perShare;
        uint256 amount;
        uint256 totalAmount;
        uint256 releaseAmount;
        uint256 lastTime;
        uint256 stopTime;

    }


    address public stakeToken;
    address public mgp;
    address public mast;
    mapping(address => MiningTokensInfo) public tokensInfos;
    address[] public tokenList;


    bool public emergency;


    mapping(address => mapping(address => UserInfo)) public userInfos;
    mapping(address => OrderInfo[]) public userOrders;
    mapping(address => uint256) public userStake;
    uint256 public totalStake;

    uint256 public lockTime = 365 days;
    uint256 public releaseTime = 365 days;

    constructor(address stakeToken_, address mgp_, address mast_) public {
        stakeToken = stakeToken_;
        mgp = mgp_;
        mast = mast_;
        tokensInfos[mgp] = MiningTokensInfo(0, 0, 0, 0, 0, 0);
        tokensInfos[mast] = MiningTokensInfo(0, 0, 0, 0, 0, 0);
        tokenList.push(mgp);
        tokenList.push(mast);
    }


    function setReleaseTime(uint256 releaseTime_) external onlyOwner {
        releaseTime = releaseTime_;
        emit SetReleaseTime(releaseTime);
    }

    function setLockTime(uint256 lockTime_) external onlyOwner {
        lockTime = lockTime_;
        emit SetLockTime(lockTime);
    }

    function setEmergency(bool emergency_) external onlyOwner {
        emergency = emergency_;
        emit SetEmergency(emergency_);
    }

    function emergencyWithdraw(address token_, uint256 amount)
    external
    onlyOwner
    {
        require(emergency, "no emergency.");
        address(token_).safeTransfer(msg.sender, amount);
    }


    modifier noContractAllowed() {
        require(
            !address(msg.sender).isContract() && msg.sender == tx.origin,
            "Sorry we do not accept contract!"
        );
        _;
    }

    modifier noEmergency() {
        require(!emergency, "emergency.");
        _;
    }

    modifier checkToken(address token) {
        require(token == mgp || token == mast, "!token");
        _;
    }

    modifier updateRewardPerShare(){
        if (totalStake > 0) {
            for (uint256 i = 0; i < tokenList.length; i++) {
                address token = tokenList[i];
                MiningTokensInfo storage tokenInfo = tokensInfos[token];
                (uint256 _reward, uint256 _perShare) = currentRewardShare(token);
                tokenInfo.perShare = _perShare;
                tokenInfo.releaseAmount = tokenInfo.releaseAmount.add(_reward);
                tokenInfo.lastTime = block.timestamp;
            }
        }
        _;
    }


    function currentRewardShare(address token)
    public
    view
    virtual
    returns (uint256 _reward, uint256 _perShare)
    {
        MiningTokensInfo storage info = tokensInfos[token];
        if (block.timestamp > info.lastTime && info.lastTime > 0) {
            // 当前区块超过stopBlock,但是上次发放没有超过stopBlock
            if (
                block.timestamp > info.stopTime &&
                info.lastTime <= info.stopTime
            ) {
                uint256 blockCount = info.stopTime.sub(info.lastTime);
                _reward = info.amount.mul(blockCount).div(1e8);
            } else if (info.lastTime > info.stopTime) {
                // 最后发放的区块超过stopBlock
                _reward = 0;
            } else if (block.number <= info.stopTime) {
                uint256 blockCount = block.timestamp.sub(info.lastTime);
                _reward = info.amount.mul(blockCount).div(1e8);
            }
            _perShare = info.perShare;
            if (totalStake > 0) {
                uint256 pendingShare = _reward.mul(1e18).div(totalStake);
                _perShare = info.perShare.add(pendingShare);
            }
            return (_reward, _perShare);
        } else {
            return (_reward, info.perShare);
        }

    }



    modifier updateUserReward(address user) {
        uint256 stakeAmount = userStake[user];
        if (stakeAmount > 0) {
            for (uint256 i = 0; i < tokenList.length; i++) {
                address token = tokenList[i];
                MiningTokensInfo storage tokenInfo = tokensInfos[token];
                UserInfo storage userInfo = userInfos[token][user];
                uint256 debt = stakeAmount.mul(tokenInfo.perShare).div(1e18);
                uint256 userReward = debt.sub(userInfo.debt);
                userInfo.reward = userInfo.reward.add(userReward);
                userInfo.debt = debt;
            }
        }
        _;
    }



    function _updateDebt(address user) internal {
        uint256 stakeAmount = userStake[user];
        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            MiningTokensInfo storage tokenInfo = tokensInfos[token];
            UserInfo storage userInfo = userInfos[token][user];
            userInfo.debt = stakeAmount.mul(tokenInfo.perShare).div(1e18);
        }
    }

    function stake(uint256 amount)
    external
    nonReentrant
    noContractAllowed
    noEmergency
    updateRewardPerShare
    updateUserReward(msg.sender)
    {
        address user = msg.sender;
        if (amount > 0) {
            userStake[user] = userStake[user].add(amount);
            _updateDebt(user);
            totalStake = totalStake.add(amount);
            stakeToken.safeTransferFrom(user, address(this), amount);

            OrderInfo memory orderInfo = OrderInfo(
                userOrders[user].length,
                block.timestamp,
                block.timestamp.add(lockTime),
                amount
            );
            userOrders[user].push(orderInfo);
            emit Stake(user, amount, orderInfo);
        }
    }

    function claimed()
    external
    nonReentrant
    noContractAllowed
    noEmergency
    updateRewardPerShare
    updateUserReward(msg.sender)
    {
        address user = msg.sender;
        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            UserInfo storage userInfo = userInfos[token][user];
            if (userInfo.reward > 0) {
                uint256 amount = userInfo.reward;
                userInfo.reward = 0;
                userInfo.income = userInfo.income.add(amount);
                address(token).safeTransfer(user, amount);
                emit Claimed(user, token, amount);
            }
        }
    }

    function withdraw(uint256[] calldata orderIds)
    external
    nonReentrant
    noContractAllowed
    noEmergency
    updateRewardPerShare
    updateUserReward(msg.sender)
    {
        address user = msg.sender;

        uint256 amount = 0;
        for (uint256 i = 0; i < orderIds.length; i = i.add(1)) {
            uint256 orderId = orderIds[i];
            OrderInfo storage order = userOrders[user][orderId];

            if (order.amount > 0 && order.endTime <= block.timestamp) {
                amount = order.amount;
                order.amount = 0;
                emit UpdateOrder(user, order);
            }
        }

        if (amount > 0) {
            require(userStake[user] >= amount, "!amount");
            userStake[user] = userStake[user].sub(amount);
            _updateDebt(user);
            totalStake = totalStake.sub(amount);
            stakeToken.safeTransfer(user, amount);
            emit Withdraw(user, amount);
        }
    }


    function income(address user)
    public
    view
    returns (uint256[] memory incomes)
    {
        incomes = new uint256[](tokenList.length);
        uint256 userAmount = userStake[user];
        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            MiningTokensInfo storage tokenInfo = tokensInfos[token];
            UserInfo storage userInfo = userInfos[token][user];

            uint256 preShare = tokenInfo.perShare;
            if (
                block.timestamp > tokenInfo.lastTime &&
                tokenInfo.lastTime > 0
            ) {
                (,preShare ) = currentRewardShare(token);
            }
            uint256 pendingDebt = userAmount.mul(preShare).div(1e18);
            uint256 pendingReward = pendingDebt.sub(userInfo.debt);
            incomes[i] = userInfo.reward.add(pendingReward);
            incomes[i] = userInfo.reward.add(pendingReward);
        }
        return incomes;
    }


    function injection(
        address token,
        uint256 amount
    ) external
    nonReentrant
    noEmergency
    checkToken(token)
    updateRewardPerShare
    {


        require(amount > 0, "!Parameter");
        token.safeTransferFrom(msg.sender, address(this), amount);
        MiningTokensInfo storage info = tokensInfos[token];
        if (info.lastTime == 0) {
            info.lastTime = block.timestamp;
        }

        // 资金进入
        info.totalAmount = info.totalAmount.add(amount);

        // 要发放的区块数量
        uint256 miningTime =releaseTime;
        uint256 currentStopTime = block.timestamp.add(miningTime);

        if (currentStopTime > info.stopTime) {
            info.stopTime = currentStopTime;
        }

        // 计算出新的每个区块产出
        uint256 time = info.stopTime.sub(info.lastTime);
        info.amount = info.totalAmount.sub(info.releaseAmount).mul(1e8).div(
            time
        );
        emit Injection(msg.sender, token, amount);

    }


    function userDepositsTotal(address user) external view returns (uint256) {
        return userOrders[user].length;
    }

    function userDepositByIndex(address user, uint256 index)
    external
    view
    returns (OrderInfo memory)
    {
        return userOrders[user][index];
    }

    function userDeposits(
        address user,
        uint256 offset,
        uint256 size
    ) external view returns (OrderInfo[] memory) {
        OrderInfo[] memory stakeList = userOrders[user];
        if (offset >= stakeList.length) {
            return new OrderInfo[](0);
        }
        // length = 2
        // offset = 0 size = 3
        // max size = 2 - 0 = 2
        if (size >= stakeList.length - offset) {
            size = stakeList.length - offset;
        }

        OrderInfo[] memory result = new OrderInfo[](size);
        for (uint256 i = 0; i < size; i++) {
            result[i] = stakeList[offset + i];
        }
        return result;
    }


}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Auth} from './Auth.sol';
import {IDEXRouter} from './interfaces/IDEXRouter.sol';
import "./interfaces/IGatewayHook.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./interfaces/IBEP20.sol";
import "./libraries/EarnHubLib.sol";

import "./interfaces/IAnyflect.sol";
import "./EarnHub.sol";

contract Anyflect is Auth, IGatewayHook, IAnyflect {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    // Event declarations
    event ReflectionsUnsubscribe(uint256 indexed tokensEarned, address, address);
    event ReflectionsSubscribe(uint stake, address, address);
    event NewReflectionPool(address);
    event ReflectionSent(address, uint);
    event GenericErrorEvent(string indexed reason);

    struct ShareHolder {
        IBEP20 selectedToken;
        address addr;
        uint256 index;
        uint256 lastClaim;
        uint256 shares;
        uint256 excludedDividends;
    }


    struct TokenPool {
        uint256 totalShares;
        uint256 tokenDividends;
        uint256 totalDistributedToken;
        uint256 dividendsPerShare;
        IBEP20 token;
        IDEXRouter router;
        uint256 index;
    }


    mapping (IBEP20 => bool) public isTokenBlacklisted;
    mapping (address => ShareHolder) public shareholders;
    uint public combinedShares;

    EnumerableMap.UintToAddressMap private activeShareHolders;
    uint public currentShareHolder; //Used to index shareholders for reflections
    bool enabledProcess = true;
    uint public totalTokenPools;

    mapping (IBEP20 => TokenPool) public tokenPools;
    mapping (address => bool) public excludedFrom;
    mapping (address => bool) public excludedTo;
    EnumerableMap.UintToAddressMap private tokenPoolAddressesIndexed;

    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    // Liquidates based on batches so that we optimize gas
    uint public batchBnbAmount;
    uint currentBatch;
    uint bnbUsedInCurrentBatch; // Should tend to 0
    uint currentLiquidationIndex; //Current index for the token in this liquidation batch
    uint batchThreshold = 0.0001 ether; // How many bnb remaining to start a new batch.
    uint batchMaxGas = 450000;
    mapping (uint => mapping (IBEP20 => bool)) liquidatedThisBatch;

    uint minPeriod = 1 seconds;

    constructor (address _earnHub) Auth(msg.sender) {
        excludedFrom[address(0)] = true;
        _authorize(_earnHub);
        transferOwnership(payable(tx.origin));
    }

    receive () external payable {
       _onReceiveBnb();
    }

    function _onReceiveBnb() public payable {
        if (msg.value == 0) {
            emit GenericErrorEvent("_onReceiveBnb(): Msg value = 0");
            return;
        }

        if (batchBnbAmount - bnbUsedInCurrentBatch <= batchThreshold) {

            _resetBnbBatch();
        }


       processBatch(batchMaxGas);
    }

    //Handles liquidations of tokens for the current bnb batch
    function processBatch(uint _batchMaxGas) public {
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();



        if (currentLiquidationIndex >= tokenPoolAddressesIndexed.length())
            _resetBatch();

        for (uint i = currentLiquidationIndex; i <= tokenPoolAddressesIndexed.length(); i++) {
            if (gasUsed > _batchMaxGas) {
                break;
            }
            (bool succ, address indexedAt) = tokenPoolAddressesIndexed.tryGet(currentLiquidationIndex);
            if (succ) {
                _triggerLiquidation(tokenPools[IBEP20(tokenPoolAddressesIndexed.get(currentLiquidationIndex))]);
            }
            currentLiquidationIndex++;

            gasUsed += (gasLeft - gasleft());
            gasLeft = gasleft();
        }
        if (batchBnbAmount - bnbUsedInCurrentBatch <= batchThreshold) {

            _resetBnbBatch();
        }
    }


    function _triggerLiquidation(TokenPool storage tokenPool) internal {
        if (address(this).balance == 0 || tokenPool.totalShares == 0) {
            return;
        }
        if (liquidatedThisBatch[currentBatch][tokenPool.token])  {
            return;
        }
        uint bnbToLiquidate = (tokenPool.totalShares * batchBnbAmount) / combinedShares;
        uint amount = bnbToLiquidate;

        // Don't liquidate if it's bnb.
        if (address(tokenPool.token) != tokenPool.router.WETH()) {
            uint256 balanceBefore = tokenPool.token.balanceOf(address(this));
            address[] memory path = new address[](2);
            path[0] = tokenPool.router.WETH();
            path[1] = address(tokenPool.token);
            tokenPool.router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbToLiquidate}(
                0,
                path,
                address(this),
                block.timestamp
            );

            amount = tokenPool.token.balanceOf(address(this)) - balanceBefore;
        }





        tokenPool.tokenDividends += amount;
        tokenPool.dividendsPerShare += dividendsPerShareAccuracyFactor * amount / tokenPool.totalShares;
        bnbUsedInCurrentBatch += bnbToLiquidate;
        liquidatedThisBatch[currentBatch][tokenPool.token] = true;
    }


    // Resets the current liquidation batch, so that we can start a new one. We should use the bnb excluded actually for the calculation
    // But since we liquidate everything in the same iteration there
    function _resetBatch() internal {

        currentLiquidationIndex = 0;
    }

    function _resetBnbBatch() internal {
        currentBatch++;
        batchBnbAmount = address(this).balance;
        bnbUsedInCurrentBatch = 0;
    }



    function processShareHolders(uint gasLimit) public {

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;



        while(gasUsed < gasLimit && iterations < activeShareHolders.length()) {
            (bool succ, address shareHolder) = activeShareHolders.tryGet(currentShareHolder);
            if (!succ) {
                currentShareHolder = 0;
                return;
            }



            if (_shouldReflect(shareholders[shareHolder]))
                _reflectRewards(shareholders[shareHolder]);

            gasUsed += (gasLeft - gasleft());
            gasLeft = gasleft();
            currentShareHolder++;
            iterations++;
        }
    }

    function _shouldReflect(ShareHolder memory _shareholder) internal returns (bool) {
        return getUnpaidEarnings(_shareholder) > 1 && _shareholder.lastClaim + minPeriod < block.timestamp;
    }

    // 1. Excludes sh from dividends
    // 2. Adds a user to reflections activeShareHolder iterable mapping
    // 3. Update pool total shares
    function _addToReflections(ShareHolder storage shareholder, IBEP20 token) internal {
        shareholder.selectedToken = token;
        // So that it doesn't give the holder gains when they start in the staking pool
        shareholder.excludedDividends = _getCumulativeDividends(shareholder);
        combinedShares += shareholder.shares;

        (bool succ, address shareHolder) = activeShareHolders.tryGet(shareholder.index);
        if (!succ || shareHolder != shareholder.addr) {
            shareholder.index = activeShareHolders.length();
            activeShareHolders.set(activeShareHolders.length(), shareholder.addr);
        }
        tokenPools[shareholder.selectedToken].totalShares += shareholder.shares;
        emit ReflectionsSubscribe(shareholder.shares, shareholder.addr, address(token));
    }

    // Creates a token pool an adds it to tokenPools and the Enumerbale mapping of it.
    function _initializeTokenPool(IDEXRouter router, IBEP20 token) internal {
        require(token.totalSupply() > 0, "Token does not exist");
        address pair = IDEXFactory(router.factory()).getPair(router.WETH(), address(token));
        require(pair != address(0) || address(token) == router.WETH(), "Pair does not exist");
        require(token.balanceOf(address(pair)) > 0 || address(token) == router.WETH(), "Token has no liquidity");

        tokenPools[token] = TokenPool(0,0,0,0, token, router, tokenPoolAddressesIndexed.length());
        tokenPoolAddressesIndexed.set(tokenPoolAddressesIndexed.length(), address(token));
        totalTokenPools++;
        emit NewReflectionPool(address (token));
    }


    // Reflects rewards to the holder
    function _reflectRewards(ShareHolder storage shareholder) internal {
        uint toPay = getUnpaidEarnings(shareholder);

        if (toPay > 0) {
            TokenPool storage tokenPool = tokenPools[shareholder.selectedToken];
            if (address(tokenPool.token) == tokenPool.router.WETH()) {
                Address.sendValue(payable(address(shareholder.addr)), toPay);
            } else {
                tokenPool.token.transfer(shareholder.addr, toPay);
            }
            shareholders[shareholder.addr].lastClaim = block.timestamp;
            tokenPool.totalDistributedToken += toPay;
            shareholder.excludedDividends = _getCumulativeDividends(shareholder);

            emit ReflectionSent(shareholder.addr, toPay);
        }

    }

    // 1. Tries to get the shareholder by index
    // 2. Removes combinedshares, selectedToken, and excludedDividends from a holder. Also removes from the iterable mapping list.
    function _removeFromReflections(ShareHolder storage shareholder) internal {
        if (shareholder.addr == address(0)) {
            emit GenericErrorEvent("_removeFromReflections(): No shares for the shareholder");
            return;
        }
        (bool succ, address a) = activeShareHolders.tryGet(shareholder.index);
        if (!succ) {
            emit GenericErrorEvent("Error removing from reflections, index for shareholder not found");
            return;
        }
        address tokenAddr = address(shareholder.selectedToken);

        // 2. Removes combinedshares, selectedToken, and excludedDividends from a holder. Also removes from the iterable mapping list.
        tokenPools[shareholder.selectedToken].totalShares -= shareholder.shares;
        combinedShares = combinedShares - shareholder.shares;
        shareholder.selectedToken = IBEP20(address (0));
        shareholder.excludedDividends = 0;

        activeShareHolders.remove(shareholder.index);
        if (address(shareholder.selectedToken) != address(0) && tokenPools[shareholder.selectedToken].totalShares == 0) {
            tokenPoolAddressesIndexed.remove(tokenPools[shareholder.selectedToken].index);
        }

        emit ReflectionsUnsubscribe(shareholder.excludedDividends, shareholder.addr, tokenAddr);
    }

    // Calculates unpaid earnings by doing
    // 1. shareholderTotalDividends = shares * poolDividends / pct
    // 2.
    function getUnpaidEarnings(ShareHolder memory shareholder) public view returns (uint256) {
        if(shareholder.shares == 0){ return 0; }

        uint256 shareholderTotalDividends = _getCumulativeDividends(shareholder);
        uint256 shareholderTotalExcluded = shareholder.excludedDividends;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getUnpaid(address shareholder) public view returns (uint256) {
        return getUnpaidEarnings(shareholders[shareholder]);
    }

    function _getCumulativeDividends(ShareHolder memory shareholder) public view returns (uint256) {
        return shareholder.shares * tokenPools[shareholder.selectedToken].dividendsPerShare /dividendsPerShareAccuracyFactor;
    }

    function depositBNB() external payable override (IGatewayHook) {
        _onReceiveBnb();
    }

    function subscribeToReflection(IDEXRouter router, IBEP20 token) external override(IAnyflect) {
        require(!isTokenBlacklisted[token], "Token is blacklisted. Talk to an admin to re-evaluate");

        ShareHolder storage sh = shareholders[msg.sender];
        if (sh.addr == address (0))
            sh.addr = msg.sender;

        // * If the token does not exist, create a token pool, initialize it's variables
        if (address(tokenPools[token].token) == address (0)) {
            _initializeTokenPool(router, token);
        }

        if (shareholders[msg.sender].shares > 0) {
            _reflectRewards(sh);
        }

        if (address(sh.selectedToken) != address (0)) {
            _removeFromReflections(sh);
        }
        _addToReflections(sh, token);
    }

    function process(EarnHubLib.Transfer memory transfer, uint gasLimit) external override (IGatewayHook) {
        require(enabledProcess, "Process disabled for this contract");
        processShareHolders(gasLimit);
    }

    function excludeFromProcess(bool _val) external authorized override(IGatewayHook, IAnyflect) {
        enabledProcess = _val;
    }

    function liquidateToken(IBEP20 _token) public {
        _triggerLiquidation(tokenPools[_token]);
    }


    // * Sets shares after every transfer so that they mirror a persons balance
    function setShares(address from, address to, uint fromBalance, uint toBalance) external override (IAnyflect) authorized {
        ShareHolder memory shFrom = shareholders[from];
        ShareHolder memory shTo = shareholders[to];
        if (!excludedFrom[from])
            _setSharesToShareholder(shFrom, fromBalance, from);
        if (!excludedTo[to])
            _setSharesToShareholder(shTo, toBalance, to);
    }

    function _setSharesToShareholder(ShareHolder memory shareholder, uint balance, address addr) internal {
        // * If the user is already subscribed to reflection, update tokenPool varibles.
        if (address(shareholder.selectedToken) != address(0)) {
            // * Update total shares and combinedShares
            TokenPool storage tokenPool = tokenPools[shareholder.selectedToken];
            tokenPool.totalShares = tokenPool.totalShares - shareholder.shares + balance;
            combinedShares = combinedShares + balance - shareholder.shares;
        }
        shareholders[addr].shares = balance;
    }

    function setExcludedTo(address from, bool val) external authorized override {
        excludedTo[from] = val;
    }

    function setExcludedFrom(address from, bool val) external  authorized override {
        excludedFrom[from] = val;
    }

    function setBatchThreshold(uint _amt) external authorized {
        batchThreshold = _amt;
    }

    function setMinPeriod(uint _period) external authorized {
        minPeriod = _period;
    }

    function setBatchMaxGas(uint _gas) external authorized {
        batchMaxGas = _gas;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only. Calls internal _authorize method
     */
    function authorize(address adr) external onlyOwner {
        _authorize(adr);
    }
    
    function _authorize (address adr) internal {
        authorizations[adr] = true;
    }
    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;


    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../libraries/EarnHubLib.sol";

interface IGatewayHook {
    //should be called only when depositBNB > 0
    function depositBNB() external payable;
    //should be called either case
    function process(EarnHubLib.Transfer memory transfer, uint gasLimit) external;
    function excludeFromProcess(bool val) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

/**
 * @dev Library for managing an enumerable variant of Solidity's
 * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
 * type.
 *
 * Maps have the following properties:
 *
 * - Entries are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Entries are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableMap for EnumerableMap.UintToAddressMap;
 *
 *     // Declare a set state variable
 *     EnumerableMap.UintToAddressMap private myMap;
 * }
 * ```
 *
 * As of v3.0.0, only maps of type `uint256 -> address` (`UintToAddressMap`) are
 * supported.
 */
library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Map type with
    // bytes32 keys and values.
    // The Map implementation uses private functions, and user-facing
    // implementations (such as Uint256ToAddressMap) are just wrappers around
    // the underlying Map.
    // This means that we can only create new EnumerableMaps for types that fit
    // in bytes32.

    struct Map {
        // Storage of keys
        EnumerableSet.Bytes32Set _keys;

        mapping (bytes32 => bytes32) _values;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    /**
     * @dev Removes a key-value pair from a map. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function _remove(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._keys.contains(key);
    }

    /**
     * @dev Returns the number of key-value pairs in the map. O(1).
     */
    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

   /**
    * @dev Returns the key-value pair stored at position `index` in the map. O(1).
    *
    * Note that there are no guarantees on the ordering of entries inside the
    * array, and it may change when more entries are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     */
    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    /**
     * @dev Same as {_get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {_tryGet}.
     */
    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }

    // UintToAddressMap

    struct UintToAddressMap {
        Map _inner;
    }

    /**
     * @dev Adds a key-value pair to a map, or updates the value for an existing
     * key. O(1).
     *
     * Returns true if the key was added to the map, that is if it was not
     * already present.
     */
    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the key was removed from the map, that is if it was present.
     */
    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {
        return _remove(map._inner, bytes32(key));
    }

    /**
     * @dev Returns true if the key is in the map. O(1).
     */
    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {
        return _contains(map._inner, bytes32(key));
    }

    /**
     * @dev Returns the number of elements in the map. O(1).
     */
    function length(UintToAddressMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

   /**
    * @dev Returns the element stored at position `index` in the set. O(1).
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    /**
     * @dev Tries to returns the value associated with `key`.  O(1).
     * Does not revert if `key` is not in the map.
     *
     * _Available since v3.4._
     */
    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    /**
     * @dev Returns the value associated with `key`.  O(1).
     *
     * Requirements:
     *
     * - `key` must be in the map.
     */
    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    /**
     * @dev Same as {get}, with a custom error message when `key` is not in the map.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryGet}.
     */
    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library EarnHubLib {
    struct Address {
        uint lastPurchase;
    }

    enum TransferType {
        Sale,
        Purchase,
        Transfer
    }

    struct Transfer {
        Address user;
        uint amt;
        TransferType transferType;
        address from;
        address to;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IDEXRouter.sol";
import "./IBEP20.sol";
import "../libraries/EarnHubLib.sol";

interface IAnyflect {
    function subscribeToReflection(IDEXRouter router, IBEP20 token) external;
    function excludeFromProcess(bool _val) external;
    function setShares(address from, address to, uint toBalance, uint fromBalance) external;
    function setExcludedFrom(address from, bool val) external;
    function setExcludedTo(address from, bool val) external;

}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Auth} from "./Auth.sol";
import "./libraries/EarnHubLib.sol";
import {EarnHubLib} from "./libraries/EarnHubLib.sol";
import {IBEP20} from "./interfaces/IBEP20.sol";
import {IDEXRouter} from "./interfaces/IDEXRouter.sol";
import {IDEXFactory} from "./interfaces/IDEXFactory.sol";
import "./interfaces/ITransferGateway.sol";
import "./interfaces/IAnyflect.sol";

import "./Anyflect.sol";

// TODO Remove all comments + Scramble function names before deploying!

// TODO Anti-Whale 1:  Depending on how much % of the liquidity pool you buy, you get the taxes waived up to a X amount.

// TODO Consider future LoyaltyTracker contract functionality and bake it into the token contract

// TODO Variable sell tax per holder

contract EarnHub is IBEP20, Auth {
    // * Event Declarations
    event GenericErrorEvent(string reason);
    event OnTransferError();
    event OnDepositError();

    address public WBNB;
    address deadAddress = 0x000000000000000000000000000000000000dEaD;
    address presaleContract;

    // Fees
    uint256 public baseSellFee = 1500; //! default floor sale Fee, always taxes higher and decays to this value after N days (see getVariableFee())
    uint256 public currentSellFee = baseSellFee;
    uint256 public maxSellFee = 0;
    uint256 public baseBuyFee = 1000;

    // Variable Fee timestamps
    uint256 public variableFeeStartingTimestamp;
    uint256 public variableFeeEndingTimestamp;

    // Convenience data
    address public pair;
    mapping(address => bool) liquidityPairs;

    string constant _name = "Test69"; //TODO CHANGE
    string constant _symbol = "Test69"; //TODO CHANGE
    uint8 constant _decimals = 9;
    uint256 public _totalSupply = 7e13 * 1e9;
    uint256 public _maxTxAmount = _totalSupply; // TODO 0.25%
    uint256 public _swapThreshold = 1000 * 1e9; // TODO Juan math How many tokens to store in the contract before triggering a liquidation event.

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) isTxLimitExempt;
    mapping(address => EarnHubLib.Address) addresses;
    mapping(address => bool) public isAnyflectExempt;

    IAnyflect public anyflect;
    IDEXRouter public router;
    ITransferGateway public transferGateway;

    // Modifier used to know if our own contract executed a swap and this transfer corresponds to a swap executed by this contract. This is used to prevent circular liquidity issues.
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address _dexRouter, ITransferGateway _transferGateway, string memory _name, string memory _symbol) Auth(msg.sender) {
        // Token Variables
        _name = _name;
        _symbol = _symbol;


        transferGateway = _transferGateway;

        anyflect = new Anyflect(address(this));
        _authorize(address(anyflect));
        _authorize(address(transferGateway));

        isFeeExempt[msg.sender] = true;
        isFeeExempt[_dexRouter] = true;
        isTxLimitExempt[msg.sender] = true;

        // Enabling Dex trading
        router = IDEXRouter(_dexRouter);
        WBNB = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        liquidityPairs[pair] = true;
        _allowances[address(this)][address(router)] = _totalSupply;
        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);
        anyflect.setExcludedFrom(pair, true);
        anyflect.setExcludedTo(pair, true);

        anyflect.setExcludedFrom(address(this), true);
        anyflect.setExcludedFrom(address(0), true);
        anyflect.setExcludedFrom(0x000000000000000000000000000000000000dEaD, true);

        _balances[msg.sender] = _totalSupply;
        // EarnHubLib.Address memory s = createOrUpdateAddress(msg.sender);
        // EarnHubLib.Transfer memory transfer = createTransfer(_totalSupply, address(0), msg.sender, EarnHubLib.TransferType.Transfer, s);

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    // Main transfer function.
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {


        if (inSwap) {return _basicTransfer(sender, recipient, amount);}

        // Anti-whale measure
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        if (_shouldSwapBack()) {_swapBack();}
        EarnHubLib.TransferType transferType = _createTransferType(sender, recipient);

        uint amountAfterFee = _shouldTakeFee(sender) ? _takeFee(sender, recipient, amount, transferType) : amount;

        // Takes the fee and keeps remainder in contract
        _balances[sender] -= amount;
        _balances[recipient] += amountAfterFee;

        EarnHubLib.Address memory s = _createOrUpdateAddress(sender);
        EarnHubLib.Transfer memory transf = _createTransfer(amount, sender, recipient, transferType, s);

        if (address(anyflect) != address(0)) {
            try anyflect.setShares(sender, recipient, _balances[sender], _balances[recipient]) {
            } catch Error (string memory reason) {
                emit GenericErrorEvent("_transferFrom(): Anyflect is not configured!");
                emit GenericErrorEvent(reason);
            }
        }

        try transferGateway.onTransfer(transf) {
        } catch Error (string memory reason) {
            emit GenericErrorEvent('_transferFrom(): transferGateway.onTransfer() failed');
            emit GenericErrorEvent(reason);
        }

        emit Transfer(sender, recipient, amountAfterFee);
        return true;
    }

    function _createOrUpdateAddress(address _addr) internal returns (EarnHubLib.Address memory) {
        //TODO contemplate updating extra attributes in Address struct in EarnHubLib
        EarnHubLib.Address memory addr = EarnHubLib.Address(block.timestamp);
        addresses[_addr] = addr;
        return addr;
    }

    function _createTransferType(address _from, address _recipient) internal view returns (EarnHubLib.TransferType) {
        if (liquidityPairs[_recipient]) {
            return EarnHubLib.TransferType.Sale;
        } else if (liquidityPairs[_from] || _from == presaleContract) {
            return EarnHubLib.TransferType.Purchase;
        }
        return EarnHubLib.TransferType.Transfer;
    }

    function _createTransfer(uint _amt, address _from, address _to, EarnHubLib.TransferType _transferType, EarnHubLib.Address memory _address) internal pure returns (EarnHubLib.Transfer memory) {
        EarnHubLib.Transfer memory _transfer = EarnHubLib.Transfer(_address, _amt, _transferType, _from, _to);
        return _transfer;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function _takeFee(address _sender, address _receiver, uint256 _amount, EarnHubLib.TransferType _transferType) internal returns (uint256) {
        uint256 feeAmount = _amount * getTotalFee(_transferType) / 10000;

        _balances[address(this)] += feeAmount;
        emit Transfer(_sender, address(this), feeAmount);

        return (_amount - feeAmount);
    }

    function _shouldSwapBack() internal view returns (bool) {
        return ((msg.sender != pair) && (!inSwap) && (_balances[address(this)] >= _swapThreshold));
    }

    function _swapBack() internal swapping {
        uint256 amountToSwap = _swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - balanceBefore;
        try transferGateway.depositBNB{value : amountBNB}() {
        } catch Error(string memory reason) {
            emit GenericErrorEvent("_swapBack(): Error depositing BNB to transfer gateway");
            emit GenericErrorEvent(reason);
        }
    }


    // * Getter (view only) Functions
    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply - balanceOf(deadAddress) - balanceOf(address(0)));
    }

    function getLiquidityBacking(uint256 _accuracy) public view returns (uint256) {
        return (_accuracy * (balanceOf(pair) * 2) / getCirculatingSupply());
    }

    function isOverLiquified(uint256 _target, uint256 _accuracy) public view returns (bool) {
        return (getLiquidityBacking(_accuracy) > _target);
    }

    function getTotalFee(EarnHubLib.TransferType _transferType) public returns (uint256) {
        if (_transferType == EarnHubLib.TransferType.Sale) {
            return maxSellFee > 0 ? getVariableSellFee() : baseSellFee;
        }
        if (_transferType == EarnHubLib.TransferType.Transfer) {
            return 0;
        }
        else {
            return baseBuyFee;
        }
    }

    function getVariableSellFee() public returns (uint256) {
        //! starts at maxSellFee then lineally decays to baseSellFee over variableTaxTimeframe

        // variable sell fee timeframe ended or timeframe hasn't started
        if (variableFeeStartingTimestamp > block.timestamp || variableFeeEndingTimestamp < block.timestamp) {
            if (variableFeeEndingTimestamp < block.timestamp) maxSellFee = 0;

            currentSellFee = baseSellFee;
            return baseSellFee;
        } else if (variableFeeStartingTimestamp <= block.timestamp || block.timestamp <= variableFeeEndingTimestamp) {// while in variable fee timeframe
            uint256 variableTaxTimeframe = variableFeeEndingTimestamp - variableFeeStartingTimestamp;
            // how much does variableFee timeframe lasts in seconds

            uint256 sellFee = baseSellFee + ((maxSellFee - baseSellFee) * (variableTaxTimeframe - (block.timestamp - variableFeeStartingTimestamp))) / variableTaxTimeframe;
            currentSellFee = sellFee;
            return sellFee;
        }
        return baseSellFee;
    }


    // * Setter (write only) Functions

    function setVariableSellFeeParams(uint256 _maxSellFee, bool _useCurrentTimestampForStart, uint256 _startingTimestamp, uint256 _endingTimestamp) public authorized {
        require(_endingTimestamp > _startingTimestamp, "_endingTimestamp should be > _startingTimestamp");
        require(_maxSellFee > baseSellFee, "_maxFee should be > baseSellFee");

        maxSellFee = _maxSellFee;
        variableFeeStartingTimestamp = _useCurrentTimestampForStart ? block.timestamp : _startingTimestamp;
        variableFeeEndingTimestamp = _endingTimestamp;
    }

    function setNewBaseFees(uint256 _newBaseBuyFee, uint256 _newBaseSellFee) external authorized {
        baseBuyFee = _newBaseBuyFee;
        baseSellFee = _newBaseSellFee;
    }

    function setTransferGateway(ITransferGateway _gateway) external authorized {
        transferGateway = _gateway;
    }

    function setAnyflect(IAnyflect _anyflect) external authorized {
        anyflect = _anyflect;
        anyflect.setExcludedFrom(pair, true);
        anyflect.setExcludedTo(pair, true);
        anyflect.setExcludedFrom(address(this), true);
        anyflect.setExcludedFrom(address(0), true);
        anyflect.setExcludedFrom(0x000000000000000000000000000000000000dEaD, true);
    }

    function setDexRouter(IDEXRouter _router) external authorized{
        router = _router;
    }

    function setTxLimit(uint256 _amount) external authorized {
        _maxTxAmount = _amount;
    }

    function setIsFeeExempt(address _holder, bool _exempt) external authorized {
        isFeeExempt[_holder] = _exempt;
    }

    function setIsTxLimitExempt(address _holder, bool _exempt) external authorized {
        isTxLimitExempt[_holder] = _exempt;
    }

    function setLiquidityPair(address _pair, bool _value) external authorized {
        liquidityPairs[_pair] = _value;
    }

    function setSwapThreshold(uint256 _amount) external authorized {
        _swapThreshold = _amount;
    }

    function setAnyflectExempt(address _addr, bool _val) external authorized {
        isAnyflectExempt[_addr] = _val;
    }

    function setPresaleContract(address _addr) external authorized {
        presaleContract = _addr;
    }

    function rescueSquad(address _to) external authorized {
        Address.sendValue(payable(address(_to)), address(this).balance);
    }

    // Grabs any shitcoin someone sends to our contract, converts it to rewards for our holders ♥
    function fuckShitcoins(IBEP20 _shitcoin, address[] memory _path, address _to) external authorized {
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _shitcoin.balanceOf(address(this)),
            0,
            _path,
            address(_to),
            block.timestamp
        );
    }

    // * Interface-compliant functions
    receive() external payable {}

    function totalSupply() external view override returns (uint256) {return _totalSupply;}

    function decimals() external pure override returns (uint8) {return _decimals;}

    function symbol() external pure override returns (string memory) {return _symbol;}

    function name() external pure override returns (string memory) {return _name;}

    function getOwner() external view override returns (address) {return owner;}

    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "../libraries/EarnHubLib.sol";
import "./IGatewayHook.sol";

interface ITransferGateway {
    function removeHookedContract(uint256 _hookedContractId) external;
    function updateHookedContractShares(uint256 _hookedContractId, uint256 _newShares) external;
    function updateHookedContractHandicap(uint256 _hookedContractId, uint256 _newHandicap) external;
    function onTransfer(EarnHubLib.Transfer memory _transfer) external;
    function setBpScale(uint256 _newBpScale) external;
    function setMinGasThreshold(uint _newMinGas) external;
    function setMaxGas(uint256 _newMaxGas) external;
    function depositBNB() external payable;
}
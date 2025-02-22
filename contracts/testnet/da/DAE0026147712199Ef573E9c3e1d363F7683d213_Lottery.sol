//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RandomNumberConsumer.sol";
import "../EGClottery.sol";

contract Lottery is RandomNumberConsumer, Ownable {
    EGClottery private EGCL;

    enum LotteryState { Registration, Open, Distribution }

    LotteryState public state = LotteryState.Registration;

    uint256 private _lotteryDistributionDay = 1;
    uint256[] public randomValues;
    
    mapping(uint256 => mapping(uint256 => address[])) private participants;
    /*
    No wallet should be able to win twice within a 48 hour period.
    */
    mapping(address => uint256) private winnersExcludedFromLottery;
    mapping(uint256 => address[]) private winnersPerDay;
    mapping(address => uint256) private lvlsForParticipants;
    mapping(uint256 => mapping(address => bool)) private isRegistred;
    mapping(address => bool) private permissionedUsers;
    mapping(uint256 => uint256) private levels;
    mapping(address => uint256) private unregisterLockPeriod;

    event WinerChosen(address indexed _winner, uint256 _amount);

    /*
    MODIFIERS
    */
    modifier onlyWithPermission {
        require(permissionedUsers[_msgSender()] == true);
        _;
    }

    modifier registrationCheck {
        require(isRegistred[_lotteryDistributionDay][_msgSender()] == false, "You've already registred!");
        require(EGCL.checkWhenBought(_msgSender()) != _lotteryDistributionDay, "You can't register today, comeback tomorrow!");
        require(winnersExcludedFromLottery[_msgSender()] < _lotteryDistributionDay, "You can't participate in the lottery 48 hours after winning");
        require(state == LotteryState.Registration, "You can't register yet");
        _;
    }

    constructor() {
        levels[1] = 1000000000000;
        levels[2] = 10000000000000;
        levels[3] = 200000000000000;
        levels[4] = 1000000000000000;
        levels[5] = 2000000000000000;
        levels[6] = 7000000000000000;
        levels[7] = 15000000000000000;
        levels[8] = 25000000000000000;
        levels[9] = 40000000000000000;
        levels[10] = 60000000000000000;
        levels[11] = 100000000000000000;
    }

    /*
    GETTER FUNCTIONS
    */
    function getLotteryState() external view returns(LotteryState) {
        return state;
    }

    function getLotteryDistributionDay() external view returns(uint256) {
        return _lotteryDistributionDay;
    }

    function getParticipant(uint256 _day, uint256 _lvl, uint256 _index) public view returns(address) {
        return participants[_day][_lvl][_index];
    }

    function getParticipantsLength(uint256 _day, uint256 _lvl) public view returns(uint256) {
        return participants[_day][_lvl].length;
    }

    function _isRegistred(uint256 _day, address _participant) external view returns(bool) {
        return isRegistred[_day][_participant];
    }

    function getLotteryEGCLbalance() public view returns(uint256) {
        return EGCL.balanceOf(address(this));
    }

    function getParticipantLevel(address _user) external view returns(uint256) {
        return lvlsForParticipants[_user];
    }

    function isExcludedWinner(address _user) external view returns(uint256) {
        return winnersExcludedFromLottery[_user];
    }

    function getRandValues(uint256 _index) external view returns(uint256) {
        return randomValues[_index];
    }

    /*
    SETTER FUNCTIONS
    */
    function setEGCLaddress(address _egcl) external onlyOwner {
        EGCL = EGClottery(_egcl);
    }

    function setPermissionedUser(address _user) external onlyOwner {
        permissionedUsers[_user] = true;
    }

    function removePermissionedUser(address _user) external onlyOwner {
        permissionedUsers[_user] = false;
    }

    function updateLotteryState() public {
        if (state == LotteryState.Registration) {
            state = LotteryState.Open;
        } else if (state == LotteryState.Open) {
            state = LotteryState.Distribution;
        } else if (state == LotteryState.Distribution) {
            state = LotteryState.Registration;
        }
    }

    function nextDistributionDay() internal onlyWithPermission {
        _lotteryDistributionDay++;
    }

    /*
        CHANGING LEVELS DISTRIBUTION LOGIC FUNCTIONS
    */
    function setLevels(
        uint256 _o, 
        uint256 _t,
        uint256 _th,
        uint256 _f,
        uint256 _fv,
        uint256 _sx,
        uint256 _svn,
        uint256 _eig,
        uint256 _nn,
        uint256 _tn,
        uint256 _end
        ) public onlyOwner {
            levels[1] = _o;
            levels[2] = _t;
            levels[3] = _th;
            levels[4] = _f;
            levels[5] = _fv;
            levels[6] = _sx;
            levels[7] = _svn;
            levels[8] = _eig;
            levels[9] = _nn;
            levels[10] = _tn;
            levels[11] = _end;
    }

    /*
        REGISTRATION
    */
    function register() external registrationCheck {
        if (
            EGCL.getBalancePerDay(_msgSender(), _lotteryDistributionDay) == 0 
            && EGCL.balanceOf(_msgSender()) > 0
            ) {
                uint256 balance = EGCL.balanceOf(_msgSender());
                uint256 share = EGCL.calculateShare(balance, _lotteryDistributionDay);
                getAllocation(_msgSender(), share, _lotteryDistributionDay);
            } else {
                uint256 balance = EGCL.getBalancePerDay(_msgSender(), _lotteryDistributionDay);
                uint256 share = EGCL.calculateShare(balance, _lotteryDistributionDay);
                getAllocation(_msgSender(), share, _lotteryDistributionDay);
            }
    }

    function mulDaysRegistration(address _holder, uint256 _share, uint256 _day, uint256 _n) external onlyWithPermission {
        require(isRegistred[_lotteryDistributionDay][_holder] == false, "You've already registred!");
        require(EGCL.checkWhenBought(_holder) != _lotteryDistributionDay, "You can't register today, comeback tomorrow!");
        require(winnersExcludedFromLottery[_holder] < _lotteryDistributionDay, "You can't participate in the lottery 48 hours after winning");
        require(state == LotteryState.Registration, "You can't register yet");

        for (_day; _day <= _n; _day++) {
            getAllocation(_holder, _share, _day);
        }
    }
    
    
    function getAllocation(address _prtspnt, uint256 _share, uint256 _day) internal {
        require(_share >= 1000000000000, "Amount of tokens isn't enough to participate in lottery :(");

        uint256 ticket = lvlsDistribution(_share);
        participants[_day][ticket].push(_prtspnt);
        isRegistred[_day][_prtspnt] = true;
        lvlsForParticipants[_msgSender()] = ticket;
    }

    /*
        DISTRIBUTION
    */
    function getRandomNumber() public override returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in the contract balance");
        require(state == LotteryState.Open, "Lottery didn't started yet");

        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = (randomness % 100000000000000000) + 1;
        randomValues = expand(randomResult, 12);
        updateLotteryState();
    }

    //!!!!!! ONLY WITH PERMISSION
    function distributeRewards() public {
        require(state == LotteryState.Distribution, "Can't distribute rewards yet");
        uint256 dividedAmount = EGCL.balanceOf(address(this))/ 12;

        for (uint256 i = 0; i < 12; i++) {
            if (randomValues[i] < 1000000000000) {
                uint256 lvl = 1;
                uint256 indx;
                (lvl, indx) = getRandomIndex(randomValues[i], i, lvl);
                transferFunds(lvl, indx, dividedAmount);
            } else {
                uint256 lvl = lvlsDistribution(randomValues[i]);
                uint256 indx;
                (lvl, indx) = getRandomIndex(randomValues[i], i, lvl);
                transferFunds(lvl, indx, dividedAmount);
            }
        }

        //excludeWinnersFromLottery();
        updateLotteryState();
        nextDistributionDay();
        randomResult = 0;
        delete randomValues;
    }

    function expand(uint256 randomValue, uint256 n) internal view onlyWithPermission returns(uint256[] memory expandedValues) {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i))) % 100000000000000000;
        }
        return expandedValues;
    }

    function getRandomIndex(uint256 randomValue, uint256 n, uint256 lvl) internal view onlyWithPermission returns(uint256, uint256) {
        uint256 length = getParticipantsLength(_lotteryDistributionDay, lvl);
        uint256 newLvl;

        if (length == 0) {

            for (lvl; lvl <= 10; lvl++) {
                length = getParticipantsLength(_lotteryDistributionDay, newLvl);
                if (length > 0) {
                    newLvl = lvl;
                    break;
                }
            }

            // If still empty array:
            if (length == 0) {

                for (lvl; lvl != 0; lvl=lvl-1) {
                    length = getParticipantsLength(_lotteryDistributionDay, lvl);
                    if (length > 0) {
                        newLvl = lvl;
                        break;
                    }
                }
            }

        return (newLvl, uint256(keccak256(abi.encode(randomValue, n))) % length);
        }
        /*
            Get random participant from lvl.
        */
        return (lvl, uint256(keccak256(abi.encode(randomValue, n))) % length);
    }

    function transferFunds(uint256 _lvl, uint256 _index, uint256 _amount) internal onlyWithPermission {
        address winner = getParticipant(_lotteryDistributionDay, _lvl, _index);

        /*
            To prevent winning lottery 
            multiple times in a row for 
            users who registred
            using mulDaysRegistration()
        */
        /*
        if (winnersExcludedFromLottery[winner] >= _lotteryDistributionDay || unregisterLockPeriod[winner] >= _lotteryDistributionDay) {
            // 12 iterations max.
            for (_index; _index < getParticipantsLength(_lotteryDistributionDay, _lvl); _index++) {
                if (winnersExcludedFromLottery[getParticipant(_lotteryDistributionDay, _lvl, _index)] < _lotteryDistributionDay) {
                    winner = getParticipant(_lotteryDistributionDay, _lvl, _index);
                } else {
                    continue;
                }
            }
        } else {
            EGCL.transfer(winner, _amount);
            //winnersExcludedFromLottery[winner] = _lotteryDistributionDay + 2;
            winnersPerDay[_lotteryDistributionDay].push(winner);

            emit WinerChosen(winner, _amount);
        }

        if (winnersExcludedFromLottery[winner] >= _lotteryDistributionDay || unregisterLockPeriod[winner] >= _lotteryDistributionDay) {
            for (_index; _index >= 0; _index++) {
                if (winnersExcludedFromLottery[getParticipant(_lotteryDistributionDay, _lvl, _index)] < _lotteryDistributionDay) {
                    winner = getParticipant(_lotteryDistributionDay, _lvl, _index);
                } else {
                    continue;
                }
            }
            EGCL.transfer(winner, _amount);
            //winnersExcludedFromLottery[winner] = _lotteryDistributionDay + 2;
            winnersPerDay[_lotteryDistributionDay].push(winner);

            emit WinerChosen(winner, _amount);
        } else {
            EGCL.transfer(winner, _amount);
            //winnersExcludedFromLottery[winner] = _lotteryDistributionDay + 2;
            winnersPerDay[_lotteryDistributionDay].push(winner);

            emit WinerChosen(winner, _amount);
        }
        */

        EGCL.transfer(winner, _amount);
        winnersExcludedFromLottery[winner] = _lotteryDistributionDay + 2;

        emit WinerChosen(winner, _amount);
    }

    function excludeWinnersFromLottery() private onlyWithPermission {
        for (uint256 i = 0; i < 12; i++) {
            winnersExcludedFromLottery[winnersPerDay[_lotteryDistributionDay][i]] += 2;
        }
    }

    function lvlsDistribution(uint256 _number) public view returns(uint256 lvl) {
        /*
            P(A) - probability of winning
            n - all outcomes
            m - outcomes favorable to event X
            P(A) = m/n

            0 <= P(A) <= 1
            levels[1] = 1000000000000;
            levels[2] = 10000000000000;
            levels[3] = 200000000000000;
            levels[4] = 1000000000000000;
            levels[5] = 2000000000000000;
            levels[6] = 7000000000000000;
            levels[7] = 15000000000000000;
            levels[8] = 25000000000000000;
            levels[9] = 40000000000000000;
            levels[10] = 60000000000000000;
            levels[11] = 100000000000000000;
        */
        
        if (_number > levels[1] && _number < levels[2]) {
            /* 
            share - 0.001 % - <0.01%
            C = 0.0001
            */
            lvl = 1;
            return lvl;
        } else if (_number >= levels[2] && _number < levels[3]) {
            /* 
            0.01 % - <0.2%
            C = 0.0019
            */
            lvl = 2;
            return lvl;
        } else if (_number >= levels[3] && _number < levels[4]) {
            /* 
            0.2 % - <1%
            C = 0.008
            */
            lvl = 3;
            return lvl;
        } else if (_number >= levels[4] && _number < levels[5]) {
            /*
            1 % - <2%
            C = 0.01
            */
            lvl = 4;
            return lvl;
        } else if (_number >= levels[5] && _number < levels[6]) {
            /*
            2 % - <7%
            C = 0.05
            */
            lvl = 5;
            return lvl;
        } else if (_number >= levels[6] && _number < levels[7]) {
            /*
            7 % - <15%
            C = 0.08
            */
            lvl = 6;
            return lvl;
        } else if (_number >= levels[7] && _number < levels[8]) {
            /*
            15 % - <25%
            C = 0.1
            */
            lvl = 7;
            return lvl;
        } else if (_number >= levels[8] && _number < levels[9]) {
            /*
            25 % - <40%
            C = 0.15
            */
            lvl = 8;
            return lvl;
        } else if (_number >= levels[9] && _number < levels[10]) {
            /*
            40 % - <60%
            C = 0.2
            */
            lvl = 9;
            return lvl;
        } else if (_number >= levels[10] && _number <= levels[11]) {
            /*
            60 % - <100%
            C = 0.4
            */
            lvl = 10;
            return lvl;
        }
    }

    function _unregisterUser(address _user, uint256 _days) external onlyWithPermission {
        if (_days >= _lotteryDistributionDay) {
            unregisterLockPeriod[_user] = _days;
        } else if (_days < _lotteryDistributionDay) {
            // Do nothing
        }
    }

    // FUNCTIONS FOR TESTING
    function setNewDayTEST() external {
        _lotteryDistributionDay++;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNumberConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    // Must be private
    uint256 public randomResult;

    /*
    BSC TESTNET
    */
    constructor() 
        VRFConsumerBase(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C,
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
        )
    {
        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18;
    }
    
    function getRandomResult() public view returns(uint256) {
        return randomResult;
    }

    function getRandomNumber() public virtual returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override {
        randomResult = randomness;
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IBEP20.sol";
import "./interfaces/IBEP20Metadata.sol";
import "./rewards/RewardsWallet.sol";
import "./lottery/Lottery.sol";
import "./lottery/LockedFunds.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EGClottery is 
    IBEP20, 
    IBEP20Metadata, 
    Ownable 
{
    using SafeMath for uint256;

    bool public disable1 = true; // WORKS!
    //https://testnet.bscscan.com/tx/0xa2b4d3720a2af3dfc062772a469de203295f0f1852509fb303e57593fccdaea5
    bool public disable2 = true; // WORKS! But need to be modified a bit
    //https://testnet.bscscan.com/tx/0x15e94e383b7532ea0befd27fec81eb4cf0d60b1a3ed1e9858fd6cf55b00cad53
    bool public disable3 = true; // ...checking...

    /* 
    BEP20
    */
    uint256 private _totalSupply;

    // BEP20 Metadata:
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;


    /*
    Dividends
    */

    /*
        Given that dividends must be distributed every 24 hours, 
        this variable calculates each day
        of the distribution of dividends.
    */
    uint256 private distributionDay = 1;
    // 24 hours
    uint256 private distributionPeriod;

    /*
        this mapping allows you to record the user's 
        balance in a certain time interval (24 hours) 
        during the transfer of funds.
    */
    mapping(address => mapping(uint256 => uint256)) private balancePerDay;
    //mapping(uint256 => uint256) private EGCBalancePerDay;
    /*
        this mapping allows you to find out 
        whether the user took his dividends 
        on a certain, past day
    */
    mapping(address => mapping(uint256 => bool)) private dividendsPerDayClaimed;
    mapping(address => uint256) private soldInDay;
    mapping(address => uint256) private boughtInDay;
    mapping(uint256 => uint256) private totalSupplyPerDay;
    mapping(address => uint256) private totalUserDividends;

    // Access control;
    mapping(address => bool) private permissionedUsers;


    event DividendsClaimed(address _beneficiary, uint256 _amount);
    event DistributionDayPassed(uint256 _newDay);
    
    /*
    ***TOKENOMICS***

    1. 6% of every transaction as passive income in EverGrow
    2. 5% of ever transaction goes to the lottery pool
    3. 3% goes to the pancakeswap liquidity pool
    4. 1% goes to a buy back and burn wallet
    */

    /* 
    Fees
    */
    uint256 private rewardsWalletFee = 6;
    uint256 private lotteryPoolFee = 5;
    uint256 private pancakeSwapLPfee = 3;
    uint256 private burn = 1;

    // For PinkSale pre-sale
    mapping(address => bool) private excludedFromFee;

    /* 
    Wallets
    */
    address private pancakeSwapLP;
    Lottery private lotteryPool;
    address private burnWallet;
    RewardsWallet private rewardsWallet;

    /* 
    Lottery
    */
    LockedFunds private lf;

    mapping(address => uint256) private multipleDaysRegistration;
    //mapping(address => uint256) private lockedAmount;

    /* 
    MODIFIERS
    */

    /*
        A modifier linked to the _transfer
        function, at each transfer of funds,
        checking whether the token distribution
        period has passed and if it has
        passed, then adds 1 day
        to the value of distributionDay.
    */

    
    modifier distributionDayCheck {
        if (disable1 == true) {
            // do nothing
        } else if (distributionPeriod < block.timestamp) {
            if (_msgSender() == address(lotteryPool)) {
                // Do nothing
            } else if (rewardsWallet.getDistributionDay() == distributionDay) {
                distributionDay++;
                distributionPeriod = block.timestamp + 6 minutes;
                rewardsWallet.setConvertionState(true);
                rewardsWallet.convertToEGC();

                lotteryPool.updateLotteryState();
                lotteryPool.getRandomNumber();
            
                emit DistributionDayPassed(distributionDay);
            }
        }
        _;
    }
  
    modifier dividendsCheck(address _sender, address _recipient, uint256 _amount) {
        if (disable2 == true) {
            // do nothing
        } else if(_sender == address(rewardsWallet) || _sender == address(lotteryPool)) {
            // do nothing
        } else if (distributionDay > 1) {
            if (_sender == pancakeSwapLP) {
                if (rewardsWallet.getEGCbalanceOfRW() > 0) {
                    if ((balanceOf(_recipient) > 0)) {
                        _claimDividends(_recipient);
                    }
            }
            } else if (_recipient == pancakeSwapLP) {
                if (rewardsWallet.getEGCbalanceOfRW() > 0) {
                    if ((balanceOf(_sender) - _amount > 0)) {
                        _claimDividends(_sender);
                    }
                }
            } else if(_sender == address(lotteryPool)) {
                // DO NOTHING @CHANGED ---> DELETE
            } else if (rewardsWallet.getEGCbalanceOfRW() > 0) {
                    if ((balanceOf(_sender) - _amount) > 0) {
                        _claimDividends(_sender);
                    }
                    
                    if (balanceOf(_recipient) > 0) {
                        _claimDividends(_recipient);
                    }
            }
        }
        _;
    }
    
    modifier onlyContract {
        require(_msgSender() == address(this), "Access denied");
        _;
    }

    modifier onlyWithPermission {
        require(permissionedUsers[_msgSender()] == true, "Access denied !OwP!");
        _;
    }

    /*
        Lottery modifiers
    */
    modifier randNumCheck(address _sender) {
        if (disable3 == true) {
            // do nothing
        } else if (lotteryPool.getRandValues(11) > 0 && _sender != address(lotteryPool)) {
            lotteryPool.distributeRewards();
        }
        _;
    }

    /*constructor(
        address _pslp,
        address _lotp,
        address _bw,
        address _rw
    ) */
    constructor(address _rw) {
        _name = "EGClottery"; // EGClottery
        _symbol = "EGCL"; // EGCL
        _decimals = 9;

        /*pancakeSwapLP = _pslp;
        lotteryPool = _lotp;
        burnWallet = _bw;
        rewardsWallet = RewardsWallet(_rw);
        */
        rewardsWallet = RewardsWallet(_rw);

        //address lockedBurnWallet;
        //address lp;
        //address teamWallet;
        //address marketingWallet;

        /*
        initial supply := 1,000,000,000,000,000

        1. 50% pre-sale
        2. 30% burn in a locked wallet
        3. 20% liquidity
        4. 7% team wallet that is locked for 1 year
        5. 3% for marketing and airdrop
        */
        uint256 initSupply = 1000000000000000*10**9;

        uint256 preSale = initSupply.div(2); // 500000000000000 EGCL ---> Pre-sale
        //amount to use in PinkSale
        _mint(msg.sender, preSale);
        uint256 burnAmount = initSupply * 30 / 100; // 300000000000000 EGCL ---> Burn and BuyBack wallet
        //_mint(0x7cF8349E8BD198caf026904f642935091A2d9a12, burnAmount);
        _mint(0xeABc22379F929Df75aC847b971c5Fa5Ab2cf9799, (burnAmount));
        _mint(_rw, burnAmount/1000000);
        //uint256 liquidity = initSupply * 20 / 100; // 200000000000000 EGCL ---> For Liquidity
        //_mint(address(this), liquidity);
        //uint256 teamWalletDist = initSupply * 7 / 100; // 70000000000000 EGCL ---> TeamWallet
        //_mint(teamWallet, teamWalletDist);
        //uint256 marketingDist = initSupply * 3 / 100; // 30000000000000 EGCL ---> Marketing
        //_mint(marketingWallet, marketingDist);

        distributionPeriod = block.timestamp + 8 minutes;
    }


    /* 
    GETTER FUNCTIONS
    <for BEP20 metadata>
    */
    function name() public view override returns (string memory) {return _name;}
    function symbol() public view override returns (string memory) {return _symbol;}
    function decimals() public view override returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function getOwner() external view override returns(address) {return owner();}


    /* 
    GETTER FUNCTIONS
    <for fees>
    */
    function getPancakeLPFee() external view returns(uint256) {
        return pancakeSwapLPfee;
    }

    function getRWFee() external view returns(uint256) {
        return rewardsWalletFee;
    }

    function getLotteryPoolFee() external view returns(uint256) {
        return lotteryPoolFee;
    }
    
    function getBurnWalletFee() external view returns(uint256) {
        return burn;
    }


    /* 
    GETTER FUNCTIONS
    <for wallets>
    */
    function getPancakeLPAddres() external view returns(address) {
        return pancakeSwapLP;
    }

    function getLotteryPoolAddress() external view returns(address) {
        return address(lotteryPool);
    }

    function getBurnWallet() external view returns(address) {
        return burnWallet;
    }

    function getRewardsWallet() external view returns(address) {
        return address(rewardsWallet);
    }


    /* 
    GETTER FUNCTIONS
    <for dividends>
    */
    function checkDividendsPerDayClaimed(address _user, uint256 _day) external view returns(bool) {
        return dividendsPerDayClaimed[_user][_day];
    }

    function checkWhenSold(address _user) external view returns(uint256) {
        return soldInDay[_user];
    }

    function checkWhenBought(address _user) public view returns(uint256) {
        return boughtInDay[_user];
    }

    function getTotalSupplyPerDay(uint256 _day) external view returns(uint256) {
        return totalSupplyPerDay[_day];
    }

    function getTotalUserDividends(address _user) external view returns(uint256) {
        return totalUserDividends[_user];
    }

    /*
    Returns current distributionDay.
    */
    function getDistributionDay() external view returns(uint256) {
        return distributionDay;
    }

    /*
    Returns balance of _sahreholder in certain day.
    */
    function getBalancePerDay(address _shareholder, uint256 _day) external view returns(uint256) {
        return balancePerDay[_shareholder][_day];
    }

    /*
    FEES SETTER FUNCTIONS
    */

    function setPancakeSwapLPfee(uint256 _amount) external onlyOwner {
        pancakeSwapLPfee = _amount;
    }

    function setLotteryPoolFee(uint256 _amount) external onlyOwner {
        lotteryPoolFee = _amount;
    }

    function setBurnWalletFee(uint256 _amount) external onlyOwner {
        burn = _amount;
    }

    function setRewardsWalletFee(uint256 _amount) external onlyOwner {
        rewardsWalletFee = _amount;
    }

    /*
    WALLETS SETTER FUNCTIONS
    */

    function setPancakeLPaddress(address _pslp) external onlyOwner {
        pancakeSwapLP = _pslp;
    }

    function setLotteryPool(address _lp) external onlyOwner {
        lotteryPool = Lottery(_lp);
    }

    function setBurnWallet(address _bw) external onlyOwner {
        burnWallet = _bw;
    }

    function setRewardsWallet(address _rw) external onlyOwner {
        rewardsWallet = RewardsWallet(_rw);
    }

    function setPermissionedUser(address _user) external onlyOwner {
        permissionedUsers[_user] = true;
    }

    function setLockedFundsAddress(address _lf) external onlyOwner {
        lf = LockedFunds(_lf);
    }

    /* 
    BEP20 SETTER FUNCTIONS
    */

    function _disable1(bool _state) external onlyOwner {
        disable1 = _state;
    }

    function _disable2(bool _state) external onlyOwner {
        disable2 = _state;
    }

    function _disable3(bool _state) external onlyOwner {
        disable3 = _state;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
                _approve(sender, msg.sender, currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
    
    // dividendsCheck(sender, recipient, amount) distributionDayCheck randNumCheck
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal distributionDayCheck dividendsCheck(sender, recipient, amount) randNumCheck(sender) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to this address is unavailable");
        
        // Checks for addresses(both sender and recipient) excluded from fees
        if (excludedFromFee[sender] == true || excludedFromFee[recipient] == true) {
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
                _balances[sender] = senderBalance - amount;

                if (_balances[sender] == 0) {
                    soldInDay[sender] = distributionDay;
                    balancePerDay[sender][distributionDay] = _balances[sender];
                } else {
                    /*
                        Here we calculate and record user's balance
                        in certain distribution day
                        to ensure that after claiming of the dividends
                        he can't transfer funds to another account
                        and claim dividends using it.
                    */
                    balancePerDay[sender][distributionDay] = _balances[sender];
                }

                if (_balances[recipient] == 0) {
                    boughtInDay[recipient] = distributionDay;
                }
                
                _balances[recipient] += amount;
                balancePerDay[recipient][distributionDay] = _balances[recipient];

                emit Transfer(sender, recipient, amount);
        } else {
        
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        /*
        Calculating the fees
        */
        uint256 EGCfee = amount.mul(rewardsWalletFee).div(100);
        uint256 lotteryFee = amount.mul(lotteryPoolFee).div(100);
        uint256 lpFee = amount.mul(pancakeSwapLPfee).div(100);
        uint256 toBurn = amount.mul(burn).div(100);

        _balances[sender] = senderBalance - amount;

            if (_balances[sender] == 0) {
                soldInDay[sender] = distributionDay;
                balancePerDay[sender][distributionDay] = _balances[sender];
            } else {
                balancePerDay[sender][distributionDay] = _balances[sender];
            }

        /*
        Distributing fees between wallets + burning
        */
        _balances[pancakeSwapLP] += lpFee;
        _balances[address(lotteryPool)] += lotteryFee;
        _balances[address(rewardsWallet)] += EGCfee;
        _balances[burnWallet] += toBurn;
        _totalSupply -= toBurn;
        totalSupplyPerDay[distributionDay] = _totalSupply;

        /*
        The final number of tokens that the user will receive with the deduction of fees
        */
        uint256 amountToRecipient = amount - EGCfee - lotteryFee - lpFee - toBurn;

        if (_balances[recipient] == 0) {
            boughtInDay[recipient] = distributionDay;
        }
             
        _balances[recipient] += amountToRecipient;
        balancePerDay[recipient][distributionDay] = _balances[recipient];

        emit Transfer(sender, recipient, amount);
            
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        totalSupplyPerDay[distributionDay] += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    /*
    WHITELIST FUNCTIONS
    */
    function excludeFromFee(address _account) external onlyOwner {
        excludedFromFee[_account] = true;
    }

    function includeFee(address _account) external onlyOwner {
        excludedFromFee[_account] = false;
    }


    /*
    DIVIDENDS FUNCTIONS
    */

    /*  
        Precondition: EGCL in RewardsWallet converted to EGC

        Function whcih can be called through RewardWallet contract
        takes as argument address of msg.sender, who called withdrawDividends()
        in RewardsWallet contract.

        Calculation of the dividends occurs due to the iteration through
        balancePerDay mapping. 

        Function calculates all recorded balances in all existed distribution days
        and converting it to the EGC dividends, which user can claim, after claiming
        dividends function resets balancePerDay for each day of itertaion and set for 
        all existed days dividendsPerDayClaimed mapping value to true, to ensure that
        user can't claim dividends from another account.
    */

    function claimDividends() external returns(bool){
        _claimDividends(_msgSender());
        return true;
    }

    function _claimDividends(address _beneficiary) internal {
        uint256 dividendsTotal;

        for (uint256 i = 1; i != distributionDay; i++) {
            /*
                This <if> condition needed to be able to claim dividends
                for users who has holding and didn't trasnfer their tokens
                and their balances for eadch day hasn't been recorded.

                Preconditions:
                1) users balance in <i> day = 0
                2) he hasn't claimed his dividends for n days
                3) his balance per current day = 0, to prevent claiming
                dividends by one user from multiple accounts. If user's
                balance on current day > 0 but he didn't transfer tokens
                for couple of previous days, he can't claim his didivdends
                for this day atm, but he can freely claim them on the next day.
                4) current balance of user is > 0;

                For example:
                X bought his tokens in [1] day and has been holding
                it 5 days long, then he decide to claim his dividends
                Calculation would be:

                    Preconditions:
                    1) for the [1] day his balance was recorded and that
                    tokens added to dividendsTotal value, but for the next
                    [2][3][4][5] days his balance wasn't recorded by balancePerDay
                    mapping, so the user balance for <i> day == 0,
                        1 precondition passed
                    2) user didn't claim his dividends in that <i> day.
                        2 precondition passed
                    3) users balance wasn't recorded in current day because he
                    didn't make any transfers.
                        3 precondition passed
                    4) users balance > 0
                        4 precondition passed

                    When all of the preconditions has passed dividends of the user calculates
                    for EGC balance of each <i> day and this value added to the dividendsTotal.
            */
            /*
                1) HOLDER
                2) TRADER
                3) HACKER
                4) Левый чел
            */
            if(
                soldInDay[_beneficiary] < i 
                && balancePerDay[_beneficiary][i] == 0
                && dividendsPerDayClaimed[_beneficiary][i] == false
                && balanceOf(_beneficiary) > 0
                && boughtInDay[_beneficiary] < i
            ) {
                dividendsTotal += calculateDividends(_beneficiary, i);
                dividendsPerDayClaimed[_beneficiary][i] = true;
            } else if (
                        soldInDay[_beneficiary] >= i
                        ) {
                dividendsTotal += 0;
            } else if (
                        balancePerDay[_beneficiary][i] == 0
                        && dividendsPerDayClaimed[_beneficiary][i] == false
                        && balanceOf(_beneficiary) == 0
                        ) {
                dividendsTotal += 0;
            } else if (
                        balancePerDay[_beneficiary][i] > 0
                        && balanceOf(_beneficiary) > 0
                        && dividendsPerDayClaimed[_beneficiary][i] == false
                        && boughtInDay[_beneficiary] < i
                        ) {
                dividendsTotal += calculateDividends(_beneficiary, i);
                dividendsPerDayClaimed[_beneficiary][i] = true;
            }
        }
            
        if (dividendsTotal == 0) {
            // do nothing
        } else {
            rewardsWallet.withdrawDividends(_beneficiary, dividendsTotal);
            addTotalUserDividends(_beneficiary, dividendsTotal);
        }
    }

    function calculateDividends(address _shareholder, uint256 _day) public view returns(uint256) {
        /*
            Function that calculates dividends in EGC token in _day,
            based on amount of tokens that user has in that _day.

            if - for users which balance in _day is recorded
            else - for users whcih balance in _day isn't recorded
        */
        
        if(balancePerDay[_shareholder][_day] > 0) {
            uint256 _balance = balancePerDay[_shareholder][_day];
            uint256 _share = calculateShare(_balance, _day);

            return rewardsWallet.getEGCbalancePerDay(_day).mul(_share.div(100)).div(10**15);
        } else {
            uint256 _balance = balanceOf(_shareholder);
            uint256 _share = calculateShare(_balance, _day);

            return rewardsWallet.getEGCbalancePerDay(_day).mul(_share.div(100)).div(10**15);
        }
    }

    function calculateShare(uint256 _bal, uint256 _day) public view returns(uint256) {
            /*
                Min avaialble perc = 1000 = 10**-24 = 0,0000000000000000000001 %
                Max available perc = 10**24 = 100%

                Percentages range:
                [1e-23 %..............1e23 %]
            */
        return _bal.mul(10**15).mul(100).div(totalSupplyPerDay[_day]);
    }

    function addTotalUserDividends(address _user, uint256 _amount) private {
        totalUserDividends[_user] += _amount;
    }

    /*
        LOTTERY FUNCTIONS
    */
    
    function _mulDaysRegistration(uint256 _days) external {
        //Register in lottery for next _days;
        require(_days <= 7, "Maximum days = 7");
        require(multipleDaysRegistration[_msgSender()] < distributionDay);
        uint256 lottDay = lotteryPool.getLotteryDistributionDay();
        uint256 share = calculateShare(balanceOf(_msgSender()), lottDay);
        uint256 balance = balanceOf(_msgSender());

        multipleDaysRegistration[_msgSender()] = lottDay + _days;
        lf._setLockedAmount(_msgSender(), balance);
        lotteryPool.mulDaysRegistration(_msgSender(), share, lottDay, _days);

        transfer(address(lf), balance);
    }

    function unregister() external {
        lotteryPool._unregisterUser(_msgSender(), multipleDaysRegistration[_msgSender()]);
        lf._unregister(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/LinkTokenInterface.sol";

import "./VRFRequestIDBase.sol";

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constuctor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBase expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomness the VRF output
   */
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

  /**
   * @dev In order to keep backwards compatibility we have kept the user
   * seed field around. We remove the use of it because given that the blockhash
   * enters later, it overrides whatever randomness the used seed provides.
   * Given that it adds no security, and can easily lead to misunderstandings,
   * we have removed it from usage and can now provide a simpler API.
   */
  uint256 private constant USER_SEED_PLACEHOLDER = 0;

  /**
   * @notice requestRandomness initiates a request for VRF output given _seed
   *
   * @dev The fulfillRandomness method receives the output, once it's provided
   * @dev by the Oracle, and verified by the vrfCoordinator.
   *
   * @dev The _keyHash must already be registered with the VRFCoordinator, and
   * @dev the _fee must exceed the fee specified during registration of the
   * @dev _keyHash.
   *
   * @dev The _seed parameter is vestigial, and is kept only for API
   * @dev compatibility with older versions. It can't *hurt* to mix in some of
   * @dev your own randomness, here, but it's not necessary because the VRF
   * @dev oracle will mix the hash of the block containing your request into the
   * @dev VRF seed it ultimately uses.
   *
   * @param _keyHash ID of public key against which randomness is generated
   * @param _fee The amount of LINK to send with the request
   *
   * @return requestId unique ID for this request
   *
   * @dev The returned requestId can be used to distinguish responses to
   * @dev concurrent requests. It is passed as the first argument to
   * @dev fulfillRandomness.
   */
  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    // This is the seed passed to VRFCoordinator. The oracle will mix this with
    // the hash of the block containing this request to obtain the seed/input
    // which is finally passed to the VRF cryptographic machinery.
    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    // nonces[_keyHash] must stay in sync with
    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
    // This provides protection against the user repeating their input seed,
    // which would result in a predictable/duplicate output, if multiple such
    // requests appeared in the same block.
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface internal immutable LINK;
  address private immutable vrfCoordinator;

  // Nonces for each VRF key from which randomness has been requested.
  //
  // Must stay in sync with VRFCoordinator[_keyHash][this]
  mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   * @param _link address of LINK token contract
   *
   * @dev https://docs.chain.link/docs/link-token-contracts
   */
  constructor(address _vrfCoordinator, address _link) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {
  /**
   * @notice returns the seed which is actually input to the VRF coordinator
   *
   * @dev To prevent repetition of VRF output due to repetition of the
   * @dev user-supplied seed, that seed is combined in a hash with the
   * @dev user-specific nonce, and the address of the consuming contract. The
   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
   * @dev the final seed, but the nonce does protect against repetition in
   * @dev requests which are included in a single block.
   *
   * @param _userSeed VRF seed input provided by user
   * @param _requester Address of the requesting contract
   * @param _nonce User-specific nonce at the time of the request
   */
  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  /**
   * @notice Returns the id for this request
   * @param _keyHash The serviceAgreement ID to be used for this request
   * @param _vRFInputSeed The seed to be passed directly to the VRF
   * @return The id for this request
   *
   * @dev Note that _vRFInputSeed is not the seed passed by the consuming
   * @dev contract, but the one generated by makeVRFInputSeed
   */
  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IBEP20.sol";

interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IPancakeFactory.sol";
import "../EGClottery.sol";

contract RewardsWallet is Ownable {
    using SafeMath for uint256;
    /*
        Variables to make swap
        EGCl -> wBNB -> EGC
    */

    // FOR TESTING: EGCL -> WBNB -> BUSD
    IBEP20 public EGC = IBEP20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
    //IBEP20 public EGC = IBEP20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    EGClottery public EGCL;
    // WBNB
    IBEP20 public WBNB = IBEP20(0x094616F0BdFB0b526bD735Bf66Eca0Ad254ca81F);
    //IBEP20 public WBNB = IBEP20(0xc778417E063141139Fce010982780140Aa0cD5Ab);
    // BAKERYSWAP ROUTER ATM
    IPancakeRouter02 public router = IPancakeRouter02(0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F);
    //IPancakeRouter02 public router = IPancakeRouter02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);


    /*
        This distributionDay variable follows distributionDay
        variable in EGClottery to calculate balance in each dist. day.
    */
    uint256 private _distributionDay = 1;

    /*
        Responsible for the ability to convert
        EGCL to EGC
    */
    bool convertionState;
    
    /*
        Needed to record EGCL balance in each _distributionDay
    */
    mapping(uint256 => uint256) private rewardsWalletEGCLBalancePerDay;
    /*
        Needed to record EGC! balance in each _distributionDay
    */
    mapping(uint256 => uint256) private EGCBalancePerDay;

    event DividendsClaimed(address _beneficiary, uint256 _amount);

    modifier onlyEGCL {
        require(_msgSender() == address(EGCL), "ACCES DENIED: you're not a EGCL contract");
        _;
    }

    function convertToEGC() public {
        require(EGCL.getDistributionDay() > _distributionDay, "You can't convert rewards yet: 1 line ERROR");
        require(convertionState == true, "You can't convert rewards yet: 2 line ERROR");

        uint256 _amountIn = EGCL.balanceOf(address(this));
        EGCL.approve(address(router), _amountIn);

        // EGCL --> wBNB --> EGC;
        address[] memory path;
        path = new address[](3);
        path[0] = address(EGCL);
        path[1] = address(WBNB);
        path[2] = address(EGC);
        
        uint256 amountOut = getAmountOutMin(address(EGCL), address(EGC), _amountIn);
        uint256 _amountOutMin = amountOut.mul(15).div(100);
        uint256 _deadline = block.timestamp + 5 minutes;
        
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, _amountOutMin, path, address(this), _deadline);
        /*
            Recording EGCL and EGC balance in current day.
        */
        rewardsWalletEGCLBalancePerDay[_distributionDay] = _amountIn;
        EGCBalancePerDay[_distributionDay] = _amountOutMin;
        _distributionDay++;
        convertionState = false;
    }

    /*
        GETTER FUNCTIONS
    */
    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) public view returns(uint256) {
        address[] memory path;
        if (_tokenIn == address(WBNB) || _tokenOut == address(WBNB)) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = address(WBNB);
            path[2] = _tokenOut;
        }

        uint256[] memory amountOutMins = router.getAmountsOut(_amountIn, path);
        return amountOutMins[path.length - 1];
    }

    function getEGCbalanceOfRW() public view returns(uint256) {
        return EGC.balanceOf(address(this));
    }

    function getEGCLbalance() public view returns(uint256) {
        return EGCL.balanceOf(address(this));
    }

    function getEGCbalancePerDay(uint256 _day) public view returns(uint256) {
        require(EGC.balanceOf(address(this)) != 0, "EGC balance of Reward Wallet is 0");
        return EGCBalancePerDay[_day];
    }

    function getConvertionState() external view returns(bool) {
        return convertionState;
    }

    function getDistributionDay() external view returns(uint256) {
        return _distributionDay;
    }

    /*
        SETTER FUNCTIONS
    */
    function setEGCLaddress(address _EGCL) external {
        EGCL = EGClottery(_EGCL);
    }

    function setConvertionState(bool _state) external {
        convertionState = _state;
    }

    function setNewEGCaddress(address _EGC) external {
        EGC = IBEP20(_EGC);
    }

    function setNewRouterAddress(address _router) external {
        router = IPancakeRouter02(_router);
    }

    //TEST
    function setEGCbalancePerDay() external {
        EGCBalancePerDay[_distributionDay] = getEGCbalanceOfRW();
    }

    function updateDistributionDay(uint256 _newDD) external {
        _distributionDay = _newDD;
    }

    /*
        Main function to withdraw dividends
        makes call to ECGL contract to calculate it
        for user in past distribution days
    */
    function withdrawDividends(address _msgS, uint256 _amount) external onlyEGCL {
        require(getEGCbalanceOfRW() > 0, "EGC balance is zero");
        require(_amount <= getEGCbalanceOfRW(), "Amount of dividends exceeds RW balance");
        EGC.transfer(_msgS, _amount);

        emit DividendsClaimed(_msgS, _amount);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../EGClottery.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract LockedFunds is Context {
    EGClottery EGCL;

    mapping(address => uint256) private lockedAmount;

    modifier onlyEGCL {
        require(_msgSender() == address(EGCL), "LF: Access denied");
        _;
    }

    constructor(address _egcl) {
        EGCL = EGClottery(_egcl);
    }

    function _setLockedAmount(address _user, uint256 _amount) external onlyEGCL {
        lockedAmount[_user] += _amount;
    }

    function _unregister(address _user) external onlyEGCL {
        require(lockedAmount[_msgSender()] > 0, "You have nothing to withdraw");

        uint256 _amount = lockedAmount[_msgSender()];
        EGCL.transfer(_msgSender(), _amount);
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IPancakeRouter01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
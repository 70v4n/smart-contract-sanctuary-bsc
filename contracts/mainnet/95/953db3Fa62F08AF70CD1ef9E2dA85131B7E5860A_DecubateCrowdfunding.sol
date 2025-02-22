// SPDX-License-Identifier: MIT

//** Decubate Crowdfunding Contract */
//** Author: Aceson & Aaron 2022.2 */

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IDecubateCrowdfunding.sol";
import "./interfaces/IDecubateInvestments.sol";
import "./interfaces/IDecubateWalletStore.sol";
import "./interfaces/IDecubateTiers.sol";

contract DecubateCrowdfunding is IDecubateCrowdfunding, Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeMath for uint8;
  using SafeERC20 for IERC20;

  /**
   *
   * @dev InvestorInfo is the struct type which store investor information
   *
   */
  struct InvestorInfo {
    uint256 joinDate;
    uint256 investAmount;
    address wallet;
    bool active;
  }

  struct InvestorAllocation {
    uint256 shares;
    bool active;
  }

  /**
   *
   * @dev AgreementInfo will have information about agreement.
   * It will contains agreement details between innovator and investor.
   * For now, innovatorWallet will reflect owner of the platform.
   *
   */
  struct AgreementInfo {
    address innovatorWallet;
    uint256 softcap;
    uint256 hardcap;
    uint256 createDate;
    uint256 startDate;
    uint256 endDate;
    uint16 gaMulti;
    IERC20 token;
    uint256 vote;
    uint256 totalInvestFund;
    mapping(address => InvestorInfo) investorList;
  }

  /* keccak256("I agree to the terms and conditions") */
  bytes32 internal constant AGREEMENT_HASH =
    0x5092667f9e8ff6ee71b4390edf6b0f5e27a1a54e802444fa8c980c19a04c550d;

  /**
   *
   * @dev this variable is the instance of wallet storage
   *
   */
  IDecubateWalletStore private _walletStore;

  /**
   *
   * @dev this variable stores total number of participants
   *
   */
  address[] private _participants;

  /**
   *
   * @dev this variable is the instance of investment contract
   *
   */
  IDecubateInvestments private _investment;

  /**
   *
   * @dev dcbAgreement store agreements info of this contract.
   *
   */
  AgreementInfo public dcbAgreement;

  /**
   *
   * @dev this variable is the instance of tiers contract
   *
   */
  IDecubateTiers private _tiers;

  /**
   *
   * @dev userAllocation stores each users allocated amount
   *
   */
  mapping(address => InvestorAllocation) public userAllocation;
  mapping(address => bool) public isComplied;

  uint8[] public weights = [5, 10, 20, 50, 100, 200];
  uint256 public totalShares;

  constructor(
    address _walletStoreAddr,
    address _investmentAddr,
    address _tiersAddr,
    address _innovator,
    uint256 _softcap,
    uint256 _hardcap,
    uint256 _startDate,
    uint16 _gaMulti,
    address _token
  ) {
    _walletStore = IDecubateWalletStore(_walletStoreAddr);
    _investment = IDecubateInvestments(_investmentAddr);
    _tiers = IDecubateTiers(_tiersAddr);

    /** generate the new agreement */
    dcbAgreement.innovatorWallet = _innovator;
    dcbAgreement.softcap = _softcap;
    dcbAgreement.hardcap = _hardcap;
    dcbAgreement.createDate = block.timestamp;
    dcbAgreement.startDate = _startDate;
    dcbAgreement.endDate = _startDate + 24 hours;
    dcbAgreement.token = IERC20(_token);
    dcbAgreement.vote = 0;
    dcbAgreement.totalInvestFund = 0;
    dcbAgreement.gaMulti = _gaMulti;

    /** emit the agreement generation event */
    emit CreateAgreement();
  }

  /**
   *
   * @dev set a users allocation
   *
   * @param {_sig} Signature from the user
   *
   * @return {bool} return status of operation
   *
   */
  function registerForAllocation(bytes memory _sig) external override returns (bool) {
    address user = ECDSA.recover(ECDSA.toEthSignedMessageHash(AGREEMENT_HASH), _sig);
    require(msg.sender == user, "Invalid signer");

    (bool _flag, uint256 _tier, uint256 _multi) = _tiers.getTierOfUser(msg.sender);

    require(_flag, "User not part of any tier");
    require(_walletStore.isVerified(msg.sender), "User is not verified");
    require(!userAllocation[msg.sender].active, "Already registered");
    require(block.timestamp <= dcbAgreement.startDate.sub(1 hours), "Registration closed");

    uint256 shares = weights[_tier].mul(_multi);

    userAllocation[msg.sender].active = true;
    userAllocation[msg.sender].shares = shares;
    isComplied[msg.sender] = true;

    totalShares = totalShares.add(shares);
    return true;
  }

  function acceptTerms(bytes memory _sign) external override returns (bool) {
    require(block.timestamp >= dcbAgreement.startDate.sub(1 hours), "Use register for allocation");
    require(_walletStore.isVerified(msg.sender), "User is not verified");

    address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(AGREEMENT_HASH), _sign);
    require(msg.sender == signer, "Invalid signer");
    isComplied[msg.sender] = true;

    return true;
  }

  /**
   *
   * @dev set the terms of the agreement
   *
   * @param {_softcap} minimum amount to raise
   * @param {_hardcap} maximum amount to raise
   * @param {_startDate} date the fundraising starts
   * @param {_gaMulti} guaranteed allocation multiplier
   * @param {_token} token being used for fundraising
   * @return {bool} return status of operation
   *
   */
  function setDCBAgreement(
    uint256 _softcap,
    uint256 _hardcap,
    uint256 _startDate,
    uint16 _gaMulti,
    address _token
  ) external override onlyOwner returns (bool) {
    dcbAgreement.softcap = _softcap;
    dcbAgreement.hardcap = _hardcap;
    dcbAgreement.startDate = _startDate;
    dcbAgreement.endDate = _startDate + 24 hours;
    dcbAgreement.token = IERC20(_token);
    dcbAgreement.gaMulti = _gaMulti;
    return true;
  }

  /**
   *
   * @dev set wallet store address for contract
   *
   * @param {_contract} address of wallet store
   * @return {bool} return status of operation
   *
   */
  function setWalletStoreAddress(address _contract) external override onlyOwner returns (bool) {
    _walletStore = IDecubateWalletStore(_contract);
    return true;
  }

  /**
   *
   * @dev set decubate investment contract address
   *
   * @param {_contract} address of investment contract
   * @return {bool} return status of operation
   *
   */
  function setInvestmentAddress(address _contract) external override onlyOwner returns (bool) {
    _investment = IDecubateInvestments(_contract);
    return true;
  }

  /**
   *
   * @dev set weight value for each tier
   *
   * @param {_values} value of each weight
   * @return {bool} return status of operation
   *
   */
  function setWeights(uint8[] calldata _values) external override onlyOwner returns (bool) {
    weights = _values;
    return true;
  }

  /**
   *
   * @dev set decubate tiers contract address
   *
   * @param {_contract} address of investment contract
   * @return {bool} return status of operation
   *
   */
  function setTiersAddress(address _contract) external override onlyOwner returns (bool) {
    _tiers = IDecubateTiers(_contract);
    return true;
  }

  /**
   *
   * @dev set innovator wallet
   *
   * @param {_innovator} address of innovator
   * @return {bool} return status of operation
   *
   */
  function setInnovatorAddress(address _innovator) external override returns (bool) {
    require(msg.sender == dcbAgreement.innovatorWallet, "Only innovator can change");
    dcbAgreement.innovatorWallet = _innovator;

    return true;
  }

  /**
   *
   * @dev investor join available agreement. Already complied users can pass empty signature
   *
   * @param {uint256} Deposit amount
   * @param {bytes} Signature of user
   *
   * @return {bool} return if investor successfully joined to the agreement
   *
   */
  function fundAgreement(uint256 _investFund) external override nonReentrant returns (bool) {
    InvestorAllocation memory user = userAllocation[msg.sender];

    /** check if investor is willing to invest any funds */
    require(_investFund > 0, "You cannot invest 0");

    /** check if startDate has started */
    require(block.timestamp >= dcbAgreement.startDate, "Crowdfunding not open");

    /** check if endDate has already passed */
    require(block.timestamp < dcbAgreement.endDate, "Crowdfunding ended");

    require(
      dcbAgreement.totalInvestFund.add(_investFund) <= dcbAgreement.hardcap,
      "Hardcap already met"
    );

    require(isComplied[msg.sender], "User has not registered");

    // is gauranteed allocation round
    bool isGa = block.timestamp < dcbAgreement.startDate.add(2 hours);

    // Allocation of user
    uint256 alloc;

    if (isGa) {
      require(user.active, "User does not have any allocation");
      alloc = getUserAllocation(msg.sender);
    } else {
      (bool _flag, uint256 _tier, uint256 _multi) = _tiers.getTierOfUser(msg.sender);
      if (_flag) {
        alloc = getAllocationForTier(uint8(_tier), uint8(_multi));
      }
    }

    // during FCFS users get multiplied allocation
    require(
      dcbAgreement.investorList[msg.sender].investAmount.add(_investFund) <=
        alloc.mul(isGa ? 10 : dcbAgreement.gaMulti).div(10),
      "Amount is greater than allocation"
    );

    if (!dcbAgreement.investorList[msg.sender].active) {
      /** add new investor to investor list for specific agreeement */
      dcbAgreement.investorList[msg.sender].wallet = msg.sender;
      dcbAgreement.investorList[msg.sender].investAmount = _investFund;
      dcbAgreement.investorList[msg.sender].joinDate = block.timestamp;
      dcbAgreement.investorList[msg.sender].active = true;
      _participants.push(msg.sender);
    }
    // user has already deposited so update the deposit
    else {
      dcbAgreement.investorList[msg.sender].investAmount = dcbAgreement
        .investorList[msg.sender]
        .investAmount
        .add(_investFund);
    }

    dcbAgreement.totalInvestFund = dcbAgreement.totalInvestFund.add(_investFund);

    _investment.setUserInvestment(
      msg.sender,
      address(this),
      dcbAgreement.investorList[msg.sender].investAmount
    );

    dcbAgreement.token.transferFrom(msg.sender, address(this), _investFund);

    emit NewInvestment(msg.sender, _investFund);

    return true;
  }

  /**
   *
   * @dev boilertemplate function for innovator to claim funds
   *
   * @param {address}
   *
   * @return {bool} return status of claim
   *
   */
  function claimInnovatorFund() external override nonReentrant returns (bool) {
    require(msg.sender == dcbAgreement.innovatorWallet, "Only innovator can claim");

    /** check if endDate already passed and softcap is reached */
    require(
      (block.timestamp >= dcbAgreement.endDate &&
        dcbAgreement.totalInvestFund >= dcbAgreement.softcap) ||
        dcbAgreement.totalInvestFund >= dcbAgreement.hardcap,
      "Date and cap not met"
    );

    /** check if treasury have enough funds to withdraw to innovator */
    require(
      dcbAgreement.token.balanceOf(address(this)) >= dcbAgreement.totalInvestFund,
      "Not enough funds in treasury"
    );

    /** 
          transfer token from treasury to innovator
      */
    dcbAgreement.token.transfer(dcbAgreement.innovatorWallet, dcbAgreement.totalInvestFund);

    emit ClaimFund();
    return true;
  }

  /**
   *
   * @dev we will have function to transfer stable coins to company wallet
   *
   * @param {address} token address
   *
   * @return {bool} return status of the transfer
   *
   */

  function transferToken(uint256 _amount, address _to) external override onlyOwner returns (bool) {
    /** check if treasury have enough funds  */
    require(dcbAgreement.token.balanceOf(address(this)) >= _amount, "Not enough funds in treasury");
    dcbAgreement.token.transfer(_to, _amount);

    emit TransferFund(_amount, _to);
    return true;
  }

  /**
   *
   * @dev Users can claim back their token if softcap isn't reached
   *
   * @return {bool} return status of the refund
   *
   */

  function refund() external override nonReentrant returns (bool) {
    /** check if user is an investor */
    require(dcbAgreement.investorList[msg.sender].wallet == msg.sender, "User is not an investor");
    /** check if softcap has already reached */
    require(dcbAgreement.totalInvestFund < dcbAgreement.softcap, "Softcap already reached");
    /** check if end date have passed or not */
    require(block.timestamp >= dcbAgreement.endDate, "End date not reached");
    uint256 _amount = dcbAgreement.investorList[msg.sender].investAmount;

    /** check if contract have enough balance*/
    require(dcbAgreement.token.balanceOf(address(this)) >= _amount, "Not enough funds in treasury");
    dcbAgreement.investorList[msg.sender].active = false;
    dcbAgreement.investorList[msg.sender].wallet = address(0);
    dcbAgreement.totalInvestFund = dcbAgreement.totalInvestFund.sub(
      dcbAgreement.investorList[msg.sender].investAmount
    );

    dcbAgreement.investorList[msg.sender].investAmount = 0;

    _investment.setUserInvestment(msg.sender, address(this), 0);

    dcbAgreement.token.transfer(msg.sender, _amount);

    emit RefundProcessed(msg.sender, _amount);

    return true;
  }

  /**
   *
   * @dev getter function for list of participants
   *
   * @return {uint256} return total participant count of crowdfunding
   *
   */
  function getParticipants() external view returns (address[] memory) {
    return _participants;
  }

  /**
   *
   * @dev Retrieve total amount of token from the contract
   *
   * @param {address} address of the token
   *
   * @return {uint256} total amount of token
   *
   */
  function getTotalToken() external view override returns (uint256) {
    return dcbAgreement.token.balanceOf(address(this));
  }

  function userInvestment(address _address)
    external
    view
    override
    returns (uint256 investAmount, uint256 joinDate)
  {
    investAmount = dcbAgreement.investorList[_address].investAmount;
    joinDate = dcbAgreement.investorList[_address].joinDate;
  }

  /**
   *
   * @dev getter function for ticket value of a tier
   *
   * @param _tier Tier value
   * @param _multi multiplier if applicable (default 1)
   *
   * @return return total participant count of crowdfunding
   *
   */
  function getAllocationForTier(uint8 _tier, uint8 _multi) public view returns (uint256) {
    return ((weights[_tier].mul(_multi).mul(dcbAgreement.hardcap)).div(totalShares));
  }

  /**
   *
   * @dev getter function for allocation of a user
   *
   * @param _address Address of the user
   *
   * @return return total participant count of crowdfunding
   *
   */
  function getUserAllocation(address _address) public view override returns (uint256) {
    return ((userAllocation[_address].shares.mul(dcbAgreement.hardcap)).div(totalShares));
  }

  /**
   *
   * @dev getter function for total participants
   *
   * @return {uint256} return total participant count of crowdfunding
   *
   */
  function getInfo()
    public
    view
    override
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    return (
      dcbAgreement.softcap,
      dcbAgreement.hardcap,
      dcbAgreement.createDate,
      dcbAgreement.startDate,
      dcbAgreement.endDate,
      dcbAgreement.totalInvestFund,
      _participants.length
    );
  }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IDecubateWalletStore {
  function addUser(address _address) external returns (bool);

  function replaceUser(address oldAddress, address newAddress) external returns (bool);

  function getVerifiedUsers() external view returns (address[] memory);

  function isVerified(address) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IDecubateTiers {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function renounceOwnership() external;

  function transferOwnership(address newOwner) external;

  function addTier(uint256 _minLimit, uint256 _maxLimit) external returns (bool);

  function setTier(
    uint256 tierId,
    uint256 _minLimit,
    uint256 _maxLimit
  ) external returns (bool);

  function getTierOfUser(address addr)
    external
    view
    returns (
      bool flag,
      uint256 pos,
      uint256 multiplier
    );

  function getTotalDeposit(address addr) external view returns (uint256 amount);

  function getTiersLength() external view returns (uint256 len);

  function tierInfo(uint256) external view returns (uint256 minLimit, uint256 maxLimit);

  function isEnabled() external view returns (bool);

  function owner() external view returns (address);
}

// SPDX-License-Identifier: MIT

//** Decubate IERC20 Library */
//** Author Vipin : Decubate Crowfunding 2021.5 */

pragma solidity ^0.8.10;

interface IDecubateInvestments {
  struct CrowdfundingEvent {
    string name;
    uint256 tokenPrice;
    string tokenSymbol;
    address vestingAddress;
    bool vestingActive;
    uint256 vestingId;
    bool isAirdrop;
    bool active;
  }

  struct UserInvestment {
    uint256 amount;
    bool active;
  }

  function addEvent(
    address _address,
    string memory name,
    uint256 tokenPrice,
    string memory tokenSymbol,
    address vestingAddress,
    bool vestingActive,
    uint256 vestingId,
    bool isAirdrop
  ) external returns (bool);

  function claimDistribution(address _account, address _crowdfunding) external returns (bool);

  function setEvent(
    address _address,
    string memory name,
    uint256 tokenPrice,
    string memory tokenSymbol,
    address vestingAddress,
    bool vestingActive,
    uint256 vestingId,
    bool isAirdrop
  ) external returns (bool);

  function setUserInvestment(
    address _address,
    address _crowdfunding,
    uint256 _amount
  ) external returns (bool);

  function getInvestmentInfo(address _account, address _crowdfunding)
    external
    view
    returns (
      string memory name,
      uint256 invested,
      uint256 tokenPrice,
      string memory tokenSymbol,
      bool vestingActive,
      bool isAirdrop
    );

  function getVestingInfo(address _account, address _crowdfunding)
    external
    view
    returns (
      uint256 startDate,
      uint256 cliff,
      uint256 duration,
      uint256 total,
      uint256 released,
      uint256 available,
      uint256 initialUnlockPercent
    );

  function getUserInvestments(address _address) external view returns (address[] memory addresses);
}

// SPDX-License-Identifier: MIT

//** Decubate Factory Contract */
//** Author Vipin */

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDecubateCrowdfunding {
  /**
   *
   * @dev this event will call when new agreement generated.
   * this is called when innovator create a new agreement but for now,
   * it is calling when owner create new agreement
   *
   */
  event CreateAgreement();

  /**
   *
   * @dev it is calling when new investor joinning to the existing agreement
   *
   */
  event NewInvestment(address wallet, uint256 amount);

  /**
   *
   * @dev Called when an investor claims refund
   *
   */
  event RefundProcessed(address wallet, uint256 amount);

  /**
   *
   * @dev this event is called when innovator claim withdrawl
   *
   */
  event ClaimFund();

  /**
   *
   * @dev this event is called when transfer fund to other address
   *
   */
  event TransferFund(uint256 amount, address to);

  /**
   *
   * inherit functions will be used in contract
   *
   */
  function setWalletStoreAddress(address _contract) external returns (bool);

  function setTiersAddress(address _contract) external returns (bool);

  function setInnovatorAddress(address _innovator) external returns (bool);

  function setInvestmentAddress(address _contract) external returns (bool);

  function setWeights(uint8[] calldata _values) external returns (bool);

  function registerForAllocation(bytes memory _sig) external returns (bool);

  function acceptTerms(bytes memory _sign) external returns (bool);

  function setDCBAgreement(
    uint256 _softcap,
    uint256 _hardcap,
    uint256 _startDate,
    uint16 _gaMulti,
    address _token
  ) external returns (bool);

  function fundAgreement(uint256 _investFund) external returns (bool);

  function claimInnovatorFund() external returns (bool);

  function refund() external returns (bool);

  function transferToken(uint256 _amount, address _to) external returns (bool);

  function userInvestment(address _address)
    external
    view
    returns (uint256 investAmount, uint256 joinDate);

  function getInfo()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    );

  function getParticipants() external view returns (address[] memory);

  function getTotalToken() external view returns (uint256);

  function getUserAllocation(address _address) external view returns (uint256);
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

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
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
pragma solidity ^0.4.11;

import '../lib/math/SafeMath.sol';
import '../token/OnyxToken.sol';

/**
 * @title TradeNetwork
 * @dev Creates and manages the trade network for onyx
 */
contract TradeNetwork is Ownable {
    using SafeMath for uint256;

    OnyxToken public Onyx;

    struct Trade {
        uint256 id;
        address from;
        address to;
        uint256 amountONYX;
        uint256 amountETH;
        bool complete;
        bool canceled;
    }

    mapping(uint256 => Trade) trades;
    uint256 public indexCounter = 0;

    event NewTrade(uint256 _id, address indexed _from, uint256 _amountONYX, uint256 _amountETH, uint256 _timestamp);
    event CloseTrade(uint256 _id, address indexed _from, address indexed _to, uint256 _amountONYX, uint256 _amountETH, uint256 _timestamp);

    function TradeNetwork(address _onyx) {
        Onyx = OnyxToken(_onyx);
    }

    modifier isApproved(uint256 _amount) {
        require(Onyx.allowance(msg.sender, this) >= _amount);
        _;
    }

    modifier isOpenTrade(uint256 _id) {
        require(trades[_id].from != 0 && trades[_id].complete == false && trades[_id].canceled == false);
        _;
    }

    /**
    * @dev Inserts a new trade onto the trade market
    * @param _amountONYX the amount of ONYX tokens the user wants to trade
    * @param _amountETH the amount of ETH the user wants in exchange
    */
    function newTrade(uint256 _amountONYX, uint256 _amountETH) isApproved(_amountONYX) returns (bool) {
        Onyx.transferFrom(msg.sender, this, _amountONYX);
        uint256 id = getId();
        trades[id] = Trade(id, msg.sender, 0, _amountONYX, _amountETH, false, false);
        NewTrade(id, msg.sender, _amountONYX, _amountETH, block.timestamp);
    }

    /**
    * @dev Cancels a trade on the trade market
    * @param _id the id of the trade to be canceled (must be the requesting account's trade)
    */
    function cancelTrade(uint256 _id) isOpenTrade(_id) returns (bool) {
        require(trades[_id].from == msg.sender);
        Onyx.transfer(msg.sender, trades[_id].amountONYX);
        trades[_id].canceled = true;
        CloseTrade(_id, msg.sender, 0, trades[_id].amountONYX, trades[_id].amountETH, block.timestamp);
    }

    /**
    * @dev Claims an open trade and pays ETH to other party to receive ONYX tokens
    * @param _id the id of the trade to be claimed (must not be the requesting account's trade)
    */
    function claimTrade(uint256 _id) payable isOpenTrade(_id) returns (bool) {
        require(trades[_id].from != msg.sender && trades[_id].amountETH == msg.value);
        Onyx.transfer(msg.sender, trades[_id].amountONYX);
        trades[_id].from.transfer(msg.value);
        trades[_id].complete = true;
        CloseTrade(_id, trades[_id].from, msg.sender, trades[_id].amountONYX, trades[_id].amountETH, block.timestamp);
    }

    /**
    * @dev Helper function to generate incrementing id
    */
    function getId() returns (uint256) {
        indexCounter = indexCounter.add(1);
        return indexCounter;
    }
}
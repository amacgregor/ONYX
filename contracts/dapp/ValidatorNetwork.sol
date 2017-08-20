pragma solidity ^0.4.11;

import '../lib/math/SafeMath.sol';
import '../token/OnyxToken.sol';
import './ReqEngContract.sol';

/**
 * @title ValidatorNetwork
 * @dev Creates and manages the validator network
 */
contract ValidatorNetwork Ownable {
    using SafeMath for uint256;

    OnyxToken Onyx;
    uint256 stake;

    struct Validator {
        uint256 stake;
        address currentAssignment;
    }

    mapping(address => Validator) validators;

    function ValidatorNetwork(address _onyx) {
        Onyx = OnyxToken(_onyx);
        stake = Onyx.getStake();
    }

    modifier isApproved() {
        if(Onyx.allowance(msg.sender, this) >= stake) {
            _;
        }
    }

    modifier isValidator() {
        if(validators[msg.sender] != 0) {
            _;
        }
    }

    function updateStake() returns (bool) {
        stake = Onyx.getStake();
    }

    function newValidator() isApproved returns (bool) {
        if(validators[msg.sender] == 0) {
            Onyx.transferFrom(msg.sender, this, stake);
            validators[msg.sender] = Validator(msg.sender, stake, false, false);
            return true;
        } else {
            return false;
        }
    }

    function getRandomValidator() constant returns (address) {
        // TODO
    }

    function validate() returns (address) {
        randomValidatorAddress = getRandomValidator();
        randomValidator = validators[randomValidatorAddress];
        randomValidator.currentAssignment = msg.sender;
        return randomValidatorAddress;
    }

    function endValidation(bool _passed) returns (bool) {
        contract = ReqEngContract(validators[msg.sender].currentAssignment);
        validators[msg.sender].currentAssignment = 0;
        contract.feedback(_passed);
        return true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract SimpleBankLedger
{
    uint private payment_no = 0;
    struct BankTransaction 
    {
        string payment_id; // payment identifier (combination of letters and digits)
        address sender; // client identifier (combination of letters and digits)
        address recipient; // recipient identifier
        uint64 amount; // amount of the payment
        uint256 tx_time; // time of the payment
        string note; // note to the payment
        // the hash value of the payment obtained by concatenating the identifiers,
        // the amount and the time of the payment and hashing the resulting string 
        // using any algorithm available in Solidity.
        bytes32 tx_hash;   
    }

    mapping(string => BankTransaction) public bank_transaction;
    mapping(address => string[]) public bank_transactions_list;

    function create_payment(address _recipient, uint64 _amount, string memory _note) public
    {
        // adds a new payment,
        string memory _payment_id = string(abi.encodePacked("payment-", Strings.toString(payment_no))); // String concantenation
        uint256 _time = block.timestamp; // time
        bytes32 _tx_hash = keccak256(abi.encodePacked(_payment_id, msg.sender, _recipient, _amount, _time)); // Transaction hash
        // Create Transaction
        BankTransaction memory transaction = BankTransaction(
            _payment_id,
            msg.sender,
            _recipient,
            _amount,
            _time,
            _note,
            _tx_hash
        ); 
        // Map transaction
        bank_transaction[_payment_id] = transaction;

        // Add transaction to map array
        bank_transactions_list[msg.sender].push(_payment_id);

        // Increment payment number
        payment_no ++;
    }

    function get_transaction_by_id(string memory _payment_id) public view returns
    (string memory, address, address, uint64, uint256, string memory, bytes32)
    {
        /* gets information about the payment by its identifier */
        return (
            bank_transaction[_payment_id].payment_id,
            bank_transaction[_payment_id].sender,
            bank_transaction[_payment_id].recipient,
            bank_transaction[_payment_id].amount,
            bank_transaction[_payment_id].tx_time,
            bank_transaction[_payment_id].note,
            bank_transaction[_payment_id].tx_hash
        );
    }

    function get_user_transactions(address user) public view returns (string [] memory)
    {
        /* gets all payments of a particular customer */ 
        return bank_transactions_list[user];
    }
}
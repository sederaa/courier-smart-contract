pragma solidity ^0.4.24;

contract Courier {
    string public code;
    address public consignor;
    address public carrier;
    uint public dispatchedTimestamp;
    uint public pickupTimestamp;
    string public pod;
    uint256 public amount;
    uint256 public pendingRefund;
    uint256 public pendingPayment;
    States public state;

    enum States {
        Dispatched,
        PickedUp,
        Delivered
    }

    constructor(string _code, address _carrier) public payable {
        consignor = msg.sender;
        code = _code;
        carrier = _carrier;
        dispatchedTimestamp = now;
        amount = msg.value;
        state = States.Dispatched;
    }
    
    modifier onlyBy(address _account)
    {
        require(msg.sender == _account, "Sender not authorized.");
        _;
    }
    
    modifier onlyInState(States _state) {
        require(state == _state, "Function cannot be called in current state.");
        _;
    }    
    
    function pickedUp() public onlyBy(carrier) onlyInState(States.Dispatched) {
        state = States.PickedUp;
        pickupTimestamp = now;
        calculateRefund();
    }
    
    function delivered(string _pod) public onlyBy(carrier) onlyInState(States.PickedUp) {
        calculateRefund();
        if (pendingRefund > 0) return;
        state = States.Delivered;
        pod = _pod;
        pendingPayment = amount;
    }
    
    function calculateRefund() public {
        if (state == States.Dispatched && dispatchedTimestamp > 0 && now - dispatchedTimestamp > 24 hours){
            pendingRefund = amount;
        }
        else if (state == States.PickedUp && pickupTimestamp > 0 && now - pickupTimestamp > 72 hours){
            pendingRefund = amount;
        }
    }
    
    function withdrawRefund() public onlyBy(consignor) {
        if (pendingRefund == 0) return;
        uint256 pendingRefundTemp = pendingRefund;
        pendingRefund = 0;
        msg.sender.transfer(pendingRefundTemp);
    }

    function withdrawPayment() public onlyBy(carrier) onlyInState(States.Delivered) {
        if (pendingPayment == 0) return;
        uint256 pendingPaymentTemp = pendingPayment;
        pendingPayment = 0;
        msg.sender.transfer(pendingPaymentTemp);
    }

    // Fallback function in case someone sends ether to the contract
   function() public payable {
       amount += msg.value;
   }
   
   // Owner can destroy contract if it is compromised, stuck or buggy
   function kill() public 
   {
      if(msg.sender == consignor) selfdestruct(consignor);
   }


}
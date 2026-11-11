// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title DueWeave
/// @notice BOT-denominated invoice funding and settlement registry.
contract DueWeave {
    enum Status { Open, Funded, Drawn, Repaid, Cancelled }
    struct Invoice { address issuer; uint128 faceValue; uint128 fundingTarget; uint128 funded; uint128 repaid; uint64 dueDate; uint16 discountBps; Status status; bytes32 referenceHash; string title; }
    uint256 public invoiceCount;
    uint256 private unlocked = 1;
    mapping(uint256 => Invoice) public invoices;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    mapping(uint256 => mapping(address => bool)) public claimed;
    event InvoiceCreated(uint256 indexed id,address indexed issuer,uint256 faceValue,uint256 fundingTarget,uint64 dueDate);
    event InvoiceFunded(uint256 indexed id,address indexed funder,uint256 amount);
    event InvoiceDrawn(uint256 indexed id,address indexed issuer,uint256 amount);
    event InvoiceRepaid(uint256 indexed id,uint256 amount);
    event SettlementClaimed(uint256 indexed id,address indexed funder,uint256 amount);
    event InvoiceCancelled(uint256 indexed id);
    modifier nonReentrant(){require(unlocked==1,"reentrant");unlocked=2;_;unlocked=1;}

    function createInvoice(string calldata title,bytes32 referenceHash,uint128 faceValue,uint16 discountBps,uint64 dueDate) external returns(uint256 id){
        require(bytes(title).length>0&&bytes(title).length<=96,"bad title");require(referenceHash!=bytes32(0),"bad reference");require(faceValue>0,"zero value");require(discountBps<=2000,"discount > 20%");require(dueDate>block.timestamp+5 minutes,"due too soon");
        uint128 target=uint128(uint256(faceValue)*(10_000-discountBps)/10_000);require(target>0,"zero target");id=++invoiceCount;invoices[id]=Invoice(msg.sender,faceValue,target,0,0,dueDate,discountBps,Status.Open,referenceHash,title);emit InvoiceCreated(id,msg.sender,faceValue,target,dueDate);
    }
    function fund(uint256 id) external payable {Invoice storage x=invoices[id];require(x.status==Status.Open,"not open");require(block.timestamp<x.dueDate,"invoice due");uint256 remaining=uint256(x.fundingTarget)-x.funded;require(msg.value>0&&msg.value<=remaining,"invalid amount");contributions[id][msg.sender]+=msg.value;x.funded+=uint128(msg.value);if(x.funded==x.fundingTarget)x.status=Status.Funded;emit InvoiceFunded(id,msg.sender,msg.value);}
    function draw(uint256 id) external nonReentrant {Invoice storage x=invoices[id];require(msg.sender==x.issuer,"issuer only");require(x.status==Status.Funded,"not funded");x.status=Status.Drawn;uint256 amount=x.funded;(bool ok,)=payable(msg.sender).call{value:amount}("");require(ok,"transfer failed");emit InvoiceDrawn(id,msg.sender,amount);}
    function repay(uint256 id) external payable {Invoice storage x=invoices[id];require(msg.sender==x.issuer,"issuer only");require(x.status==Status.Drawn,"not drawn");require(msg.value==x.faceValue,"send face value");x.repaid=uint128(msg.value);x.status=Status.Repaid;emit InvoiceRepaid(id,msg.value);}
    function claim(uint256 id) external nonReentrant {Invoice storage x=invoices[id];require(x.status==Status.Repaid,"not repaid");uint256 share=contributions[id][msg.sender];require(share>0&&!claimed[id][msg.sender],"nothing to claim");claimed[id][msg.sender]=true;uint256 amount=share*x.faceValue/x.fundingTarget;(bool ok,)=payable(msg.sender).call{value:amount}("");require(ok,"transfer failed");emit SettlementClaimed(id,msg.sender,amount);}
    function cancel(uint256 id) external {Invoice storage x=invoices[id];require(msg.sender==x.issuer,"issuer only");require(x.status==Status.Open,"not open");x.status=Status.Cancelled;emit InvoiceCancelled(id);}
    function refund(uint256 id) external nonReentrant {Invoice storage x=invoices[id];require(x.status==Status.Cancelled||(x.status==Status.Open&&block.timestamp>=x.dueDate),"refund unavailable");uint256 amount=contributions[id][msg.sender];require(amount>0,"nothing to refund");contributions[id][msg.sender]=0;(bool ok,)=payable(msg.sender).call{value:amount}("");require(ok,"transfer failed");}
}

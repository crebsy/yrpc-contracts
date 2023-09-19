# @version 0.3.9

from vyper.interfaces import ERC20

owner: public(address)
pending_owner: public(address)
token: public(ERC20)
fee_recipient: public(address)

event TopupReceived:
    user: indexed(address)
    amount: uint256

@external
def __init__(token_address: address, fee_recipient: address):
  self.owner = msg.sender
  self.token = ERC20(token_address)
  self.fee_recipient = fee_recipient

@external
def set_owner(new_owner: address):
  assert msg.sender == self.owner, "unauthorized"
  self.pending_owner = new_owner

@external
def accept_owner():
  assert msg.sender == self.pending_owner, "unauthorized"
  self.owner = self.pending_owner
  self.pending_owner = empty(address)

@external
def set_fee_recipient(new_fee_recipient: address):
  assert msg.sender == self.owner, "unauthorized"
  self.fee_recipient = new_fee_recipient

@external
def topup(amount: uint256):
  assert amount > 0, "topup amount too small"
  self.token.transferFrom(msg.sender, self.fee_recipient, amount)
  log TopupReceived(msg.sender, amount)

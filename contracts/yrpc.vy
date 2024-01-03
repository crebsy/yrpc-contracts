# @version 0.3.10

from vyper.interfaces import ERC20

owner: public(address)
pending_owner: public(address)
fee_token: public(ERC20)
fee_recipient: public(address)
fee_rate: public(uint256)

event TopupReceived:
  apiKeyHash: String[64]
  topupToken: address
  topupAmount: uint256
  topupBalance: uint256
  feeRate: uint256

@external
def __init__(fee_token_address: address, fee_recipient: address, fee_rate: uint256):
  assert fee_token_address != empty(address), "fee_token_address can't be ZERO_ADDRESS"
  assert fee_recipient != empty(address), "fee_recipient can't be ZERO_ADDRESS"
  assert fee_rate > 0, "fee_rate too small"
  self.owner = msg.sender
  self.fee_token = ERC20(fee_token_address)
  self.fee_recipient = fee_recipient
  self.fee_rate = fee_rate

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
def set_fee_rate(new_fee_rate: uint256):
  assert msg.sender == self.owner, "unauthorized"
  assert new_fee_rate > 0, "new_fee_rate too small"
  self.fee_rate = new_fee_rate

@external
def topup(apiKeyHash: String[64], topupAmount: uint256):
  assert topupAmount >= self.fee_rate, "topup amount too small"
  self.fee_token.transferFrom(msg.sender, self.fee_recipient, topupAmount)

  topupBalance: uint256 = topupAmount / self.fee_rate
  log TopupReceived(
    apiKeyHash,
    self.fee_token.address,
    topupAmount,
    topupBalance,
    self.fee_rate
  )

require File.expand_path('../test_helper', __FILE__)

class APITest < Test::Unit::TestCase
  def setup
    @api = Supreme::API.new
  end
  
  def test_banklist
    @api.stubs(:get).returns(mock(:ok? => true, :body => BANKLIST_RESPONSE))
    assert_equal [["ABN AMRO", "0031"], ["Postbank", "0721"], ["Rabobank", "0021"]], @api.banklist
  end
end

BANKLIST_RESPONSE = %(<?xml version="1.0"?>
<response>
    <bank>
        <bank_id>0031</bank_id>
        <bank_name>ABN AMRO</bank_name>
    </bank>
    <bank>
        <bank_id>0721</bank_id>
        <bank_name>Postbank</bank_name>
    </bank>
    <bank>
        <bank_id>0021</bank_id>
        <bank_name>Rabobank</bank_name>
    </bank>
    <message>This is the current list of banks and their ID's that currently support iDEAL-payments</message>
</response>)
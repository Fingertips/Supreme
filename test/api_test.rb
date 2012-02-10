require File.expand_path('../test_helper', __FILE__)

class Supreme::APITest < Test::Unit::TestCase
  def setup
    @api = Supreme::API.new(
      :partner_id => '000000'
    )
  end
  
  def test_banklist
    @api.stubs(:get).with('https://secure.mollie.nl/xml/ideal?a=banklist').returns(mock(:ok? => true, :body => BANKLIST_RESPONSE))
    assert_equal [["ABN AMRO", "0031"], ["Postbank", "0721"], ["Rabobank", "0021"]], @api.banklist
  end
  
  def test_fetch
    @api.stubs(:get).returns(mock(:ok? => true, :body => BANKLIST_RESPONSE))
    transaction = @api.fetch(
      :bank_id => '0031',
      :amount => 1299,
      :description => '20 credits for your account',
      :report_url => 'http://example.com/payments/ad74hj23',
      :return_url => 'http://example.com/payments/ad74hj23/thanks'
    )
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

FETCH_RESPONSE = %(<?xml version="1.0"?>
<response>
    <order>
        <transaction_id>482d599bbcc7795727650330ad65fe9b </transaction_id>
        <amount>123</amount>
        <currency>EUR</currency>
        <URL>https://mijn.postbank.nl/internetbankieren/SesamLoginServlet?sessie=ideal&trxid=003123456789123&random=123456789abcdefgh</URL>
        <message>Your iDEAL-payment has succesfuly been setup. Your customer should visit the given URL to make the payment</message>
    </order>
</response>)
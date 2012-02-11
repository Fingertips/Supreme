require File.expand_path('../test_helper', __FILE__)

class Supreme::APITest < Test::Unit::TestCase
  def setup
    FakeWeb.clean_registry
    
    @api = Supreme::API.new(
      :partner_id => '978234'
    )
    
    @record_url = proc { |url| @url = url }
    @fetch_options = {
      :bank_id => '0031',
      :amount => 1299,
      :description => '20 credits for your account',
      :report_url => 'http://example.com/payments/ad74hj23',
      :return_url => 'http://example.com/payments/ad74hj23/thanks'
    }
    @status_options = {
      :transaction_id => '482d599bbcc7795727650330ad65fe9b'
    }
  end
  
  def test_banklist_url
    REST.stubs(:get).with(&@record_url).returns(stub(:ok? => false))
    @api.send(:get, 'banklist')
    
    uri = URI.parse(@url)
    assert_equal 'https', uri.scheme
    assert_equal 'secure.mollie.nl', uri.host
    assert_equal '/xml/ideal', uri.path
    
    parts = Hash[Supreme::URI.parse_query(uri.query)]
    assert_equal({
      'testmode' => 'true',
      'a' => 'banklist'
    }, parts)
  end
  
  def test_banklist
    FakeWeb.register_uri(:get, %r{^https://}, :body => BANKLIST_RESPONSE, :status => 200)
    banklist = @api.banklist
    assert banklist.kind_of?(Supreme::Banklist)
    assert_equal [
      {:name=>"ABN AMRO", :id=>"0031"},
      {:name=>"Postbank", :id=>"0721"},
      {:name=>"Rabobank", :id=>"0021"}
    ], banklist.to_a
  end
  
  def test_fetch_url
    REST.stubs(:get).with(&@record_url).returns(stub(:ok? => false))
    @api.fetch(@fetch_options)
    uri = URI.parse(@url)
    assert_equal 'https', uri.scheme
    assert_equal 'secure.mollie.nl', uri.host
    assert_equal '/xml/ideal', uri.path
    
    parts = Hash[Supreme::URI.parse_query(uri.query)]
    assert_equal({
      "a" => "fetch",
      "testmode" => "true",
      "amount" => "1299",
      "bank_id" => "0031",
      "description" => "20 credits for your account",
      "partner_id" => "978234",
      "returnurl" => "http://example.com/payments/ad74hj23/thanks",
      "reporturl" => "http://example.com/payments/ad74hj23"
    }, parts)
  end
  
  def test_fetch
    FakeWeb.register_uri(:get, %r{^https://}, :body => FETCH_RESPONSE, :status => 200)
    transaction = @api.fetch(@fetch_options)
    assert transaction.kind_of?(Supreme::Transaction)
    assert_equal '482d599bbcc7795727650330ad65fe9b', transaction.transaction_id
    assert_equal '123', transaction.amount
    assert_equal 'https://mijn.postbank.nl/internetbankieren/SesamLoginServlet?sessie=ideal&trxid=003123456789123&random=123456789abcdefgh', transaction.url
  end
  
  def test_status_url
    REST.stubs(:get).with(&@record_url).returns(stub(:ok? => false))
    @api.status(@status_options)
    uri = URI.parse(@url)
    assert_equal 'https', uri.scheme
    assert_equal 'secure.mollie.nl', uri.host
    assert_equal '/xml/ideal', uri.path
    
    parts = Hash[Supreme::URI.parse_query(uri.query)]
    assert_equal({
      "a" => "fetch",
      "testmode" => "true",
      "partner_id" => "978234",
      "transaction_id" => "482d599bbcc7795727650330ad65fe9b"
    }, parts)
  end
  
  def test_status
    FakeWeb.register_uri(:get, %r{^https://}, :body => STATUS_RESPONSE, :status => 200)
    status = @api.status(@status_options)
    assert status.kind_of?(Supreme::Status)
    assert_equal '482d599bbcc7795727650330ad65fe9b', status.transaction_id
    assert_equal '123', status.amount
    assert_equal 'EUR', status.currency
    assert_equal 'true', status.paid
    assert_equal({
      'name' => 'Hr J Janssen',
      'account' => 'P001234567',
      'city' => 'Amsterdam'
    }, status.customer)
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
        <transaction_id>482d599bbcc7795727650330ad65fe9b</transaction_id>
        <amount>123</amount>
        <currency>EUR</currency>
        <URL>https://mijn.postbank.nl/internetbankieren/SesamLoginServlet?sessie=ideal&trxid=003123456789123&random=123456789abcdefgh</URL>
        <message>Your iDEAL-payment has succesfuly been setup. Your customer should visit the given URL to make the payment</message>
    </order>
</response>)

STATUS_RESPONSE = %(<?xml version="1.0"?>
<response>
    <order>
        <transaction_id>482d599bbcc7795727650330ad65fe9b</transaction_id>
        <amount>123</amount>
        <currency>EUR</currency>
        <payed>true</payed>
        <consumer>
            <consumerName>Hr J Janssen</consumerName>
            <consumerAccount>P001234567</consumerAccount>
            <consumerCity>Amsterdam</consumerCity>
        </consumer>
        <message>This iDEAL-order has successfuly been payed for, and this is the first time you check it.</message>
    </order>
</response>)
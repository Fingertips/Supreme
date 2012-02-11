require File.expand_path('../test_helper', __FILE__)

class BasicTest < Test::Unit::TestCase
  def setup
    Supreme.mode = :test
  end
  
  def test_banklist
    banklist = Supreme.api.banklist
    assert !banklist.to_a.empty?
  end
  
  def test_setup_transaction
    bank_id = Supreme.api.banklist.to_a[0][:id]
    transaction = Supreme.api.fetch(
      :bank_id     => bank_id,
      :amount      => 1399,
      :description => 'Fluffy bunny',
      :report_url  => 'http://example.com/payment/report',
      :return_url  => 'http://example.com/payment/thanks'
    )
    puts "Open the following link and complete the transaction: "
    puts transaction.url
  end
end
require File.expand_path('../test_helper', __FILE__)

Supreme.mode = :test

banklist = Supreme.api.banklist
assert(!banklist.to_a.empty?, "Expected the banklist to not be empty")

bank_id = banklist.to_a[0][:id]
transaction = Supreme.api.fetch(
  :bank_id     => bank_id,
  :amount      => 1399,
  :description => 'Fluffy bunny',
  :report_url  => 'http://example.com/payment/report',
  :return_url  => 'http://example.com/payment/thanks'
)
assert(transaction.transaction_id.strip != '', "Expected the transaction_id to not be empty")

puts
puts "Open the following link and complete the transaction: "
puts transaction.url
puts

puts "Waiting 20 seconds for you to complete the payment"
20.times { $stdout.write('.'); sleep 1 }
puts

transaction_id = transaction.transaction_id
status = Supreme.api.check(:transaction_id => transaction_id)
assert(1399 == status.amount.to_i, "Expected the status amount to be the same as the one we set (was #{status.amount})")

if status.success?
  puts "The transation was completed successfully!"
else
  puts "The transation failed: #{status.status}"
end
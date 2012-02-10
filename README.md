A Ruby client that allows you to do iDEAL transactions through the [Mollie iDEAL API](http://www.mollie.nl/betaaldiensten/ideal).

## Install

$ gem install supreme

## Examples
  
  # Mode is either :test or :live, by default it's :test
  Supreme.mode = :test 
  
  Supreme.api.bank_list #=> [["ABN AMRO", "0031"], ["Postbank", "0721"], ["Rabobank", "0021"]]
  
  transaction = Supreme.api.fetch({
    :partner_id => '000000',
    :bank_id => '0031',
    :amount => 1299,
    :description => 'A fluffy bunny',
    :return_url => 'http://example.com/payments/as45re/thanks',
    :report_url => 'http://example.com/payments/as45re'
  })
  
  transaction.transaction_id #=> '482d599bbcc7795727650330ad65fe9b'
  
You will receive a GET on the report_url with a ‘transaction_id’ parameter to indicate that the transaction has changed state. You will need to check the status of the transaction.
  
  status = Supreme.api.status({
    :partner_id => '000000',
    :transaction_id => '482d599bbcc7795727650330ad65fe9b'
  })
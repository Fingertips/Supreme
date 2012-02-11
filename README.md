A Ruby client that allows you to do iDEAL transactions through the [Mollie iDEAL API](http://www.mollie.nl/betaaldiensten/ideal).

[ ![Travis-CI badge](https://secure.travis-ci.org/Fingertips/Supreme.png) ](http://travis-ci.org/Fingertips/Supreme )

## Install

$ gem install supreme

## Payment flow

You start by setting the mode of the library to either :test or :live. The default is :test, so
for tests you don't have to change anything.
  
    Supreme.mode = :live

You can choose to set the partner (client) id globally so you don't have to include it with every
call.

    Supreme.partner_id = '000000'

Then you get a list of supported banks. Note that this list can change at any time, so be conservative
with caching these values.

    Supreme.api.bank_list #=> [["ABN AMRO", "0031"], ["Postbank", "0721"], ["Rabobank", "0021"]]

When the user has selected a bank, you start a transaction.

    transaction = Supreme.api.fetch(
      :bank_id => '0031',
      :amount => 1299,
      :description => 'A fluffy bunny',
      :return_url => 'http://example.com/payments/as45re/thanks',
      :report_url => 'http://example.com/payments/as45re'
    )
    transaction.transaction_id #=> '482d599bbcc7795727650330ad65fe9b'

Keep the transaction_id around for reference and redirect the customer to the indicated URL.

    Location: #{transaction.url}

Once the transaction is done you will receive a GET on the report_url with a ‘transaction_id’ parameter
to indicate that the transaction has changed state. You will need to check the status of the transaction.
  
    status = Supreme.api.check(
      :transaction_id => '482d599bbcc7795727650330ad65fe9b'
    )
  
    # Note that the status will only be paid? after the first check, for each consecutive call
    # paid? will be false regardless of the outcome of the transaction.
    #
    # We use success? and make sure we don't deliver the product more than once.
    if status.success?
      # Update the local status of the payment
    end

When the customer returns to your site it returns with its transaction_id attached to your provided URL.
You can present a page depending on the status of the payment.

## Errors

When an error occurs you get a Supreme::Error object instead of the response object you expected.

    status = Supreme.api.check(
      :transaction_id => '482d599bbcc7795727650330ad65fe9b'
    )
    
    if status.error?
      log("#{status.message} (#{status.code})")
    end
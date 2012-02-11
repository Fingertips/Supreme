require 'rexml/document'

module Supreme
  # The base class for all response classes.
  class Response
    attr_accessor :body
    
    def initialize(body)
      @body = body
    end
    
    def error?
      false
    end
    
    # Return an instance of a reponse class based on the contents of the body
    def self.for(response_body, klass)
      body = REXML::Document.new(response_body).root
      if body.elements["/response/item"]
        ::Supreme::Error.new(body)
      else
        klass.new(body)
      end
    end
    
    protected
    
    def text(path)
      @body.get_text(path).to_s
    end
  end
  
  # Response to a banklist request
  class Banklist < Response
    def to_a
      @body.get_elements('//bank').map do |issuer|
        { :id => issuer.get_text('bank_id').to_s, :name => issuer.get_text('bank_name').to_s }
      end
    end
  end
  
  # Response to a fetch request
  class Transaction < Response
    def transaction_id
      text('//transaction_id')
    end
    
    def amount
      text('//amount')
    end
    
    def url
      text('//URL')
    end
  end
  
  # Response to a check request
  class Status < Response
    def transaction_id
      text('//transaction_id')
    end
    
    def amount
      text('//amount')
    end
    
    def currency
      text('//currency')
    end
    
    def paid
      text('//payed')
    end
    
    # A payment will return paid? for just one request. If you issue it too early you might never
    # get a truthy value from this.
    def paid?
      paid == 'true'
    end
    
    # Returns the status of the payment. This is probably the best way to check if the payment has
    # succeeded. It returns one of the following values:
    #
    # * <tt>Open</tt> – Payment is still processing.
    # * <tt>Success</tt> – The payment was successful.
    # * <tt>Cancelled</tt> – The payment was explicitly cancelled by the customer.
    # * <tt>Failure</tt> – The payment failed.
    # * <tt>Expired</tt> – The customer abandoned the payment, we don't expect them to finish it.
    # * <tt>CheckedBefore</tt> – You've requested the payment status before.
    #
    # You can also check the status of the payment with one of the boolean accessors: open?, success?,
    # cancelled?, failed?, expired?, and checked_before?.
    def status
      text('//status')
    end
    
    [
      ['Open', :open?],
      ['Success', :success?],
      ['Cancelled', :cancelled?],
      ['Failure', :failed?],
      ['Expired', :expired?],
      ['CheckedBefore', :checked_before?]
    ].each do |expected, accessor|
      define_method accessor do
        status == expected
      end
    end
    
    def customer
      {
        'name' => text('//consumerName'),
        'account' => text('//consumerAccount'),
        'city' => text('//consumerCity')
      }
    end
  end
  
  # Response was an error
  class Error < Response
    def error?
      true
    end
    
    def code
      text('//errorcode')
    end
    
    def message
      text('//message')
    end
  end
end

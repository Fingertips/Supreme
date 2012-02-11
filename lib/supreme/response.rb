require 'rexml/document'

module Supreme
  # The base class for all response classes.
  class Response
    attr_accessor :response
    
    def initialize(response_body)
      @response = REXML::Document.new(response_body).root
    end
    
    protected
    
    def text(path)
      @response.get_text(path).to_s
    end
  end
  
  # Response to a banklist request
  class Banklist < Response
    def to_a
      @response.get_elements('//bank').map do |issuer|
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
    
    def paid?
      paid == 'true'
    end
    
    def customer
      {
        'name' => text('//consumerName'),
        'account' => text('//consumerAccount'),
        'city' => text('//consumerCity')
      }
    end
  end
end

require 'rest'
require 'nokogiri'

module Supreme
  class API
    attr_accessor :partner_id
    
    def initialize(options={})
      self.partner_id = options[:partner_id] || Supreme.partner_id
    end
    
    # Returns a list of available banks
    def banklist
      response = get('https://secure.mollie.nl/xml/ideal?a=banklist')
      if response.ok?
        document = Nokogiri::XML.parse(response.body)
        document.xpath('//bank').map do |bank_element|
          bank_id = bank_element.xpath('bank_id')[0].content
          bank_name = bank_element.xpath('bank_name')[0].content
          [bank_name, bank_id]
        end
      end
    end
    
    # Fetches a new transaction
    def fetch(options)
      response = get("https://secure.mollie.nl/xml/ideal?a=fetch&#{Supreme::URI.generate_query(options)}")
      if response.ok?
        response.body
      end
    end
    
    private
    
    def get(url)
      REST.get(url)
    end
  end
end
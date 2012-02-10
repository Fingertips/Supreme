require 'rest'
require 'nokogiri'

class Supreme
  class API
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
    
    def get(url)
      REST.get(url)
    end
  end
end
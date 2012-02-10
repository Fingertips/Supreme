require 'uri'
require 'rest'

module Supreme
  class API
    ENDPOINT = ::URI.parse("https://secure.mollie.nl/xml/ideal")
    
    attr_accessor :partner_id
    
    def initialize(options={})
      self.partner_id = options[:partner_id] || Supreme.partner_id
    end
    
    # Returns a list of available banks
    def banklist
      response = get('banklist')
      if response.ok?
        Supreme::Banklist.new(response.body)
      end
    end
    
    # Fetches a new transaction
    def fetch(options)
      options = options.dup
      options[:partner_id] ||= partner_id
      response = get('fetch', Supreme.translate_hash_keys({
        :return_url => :returnurl,
        :report_url => :reporturl
      }, options))
      if response.ok?
        Supreme::Transaction.new(response.body)
      end
    end
    
    private
    
    def endpoint
      ENDPOINT.dup
    end
    
    def query(options={})
      options = options.dup
      options[:testmode] = 'true' if Supreme.test?
      options == {} ? nil : Supreme::URI.generate_query(options)
    end
    
    def get(action, options={})
      options = options.dup
      options[:a] = action
      url = endpoint
      url.query = query(options)
      REST.get(url.to_s)
    end
  end
end
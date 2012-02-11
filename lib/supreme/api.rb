require 'uri'
require 'rest'

module Supreme
  class API
    ENDPOINT = ::URI.parse("https://secure.mollie.nl/xml/ideal")
    
    attr_accessor :mode, :partner_id
    
    # Creates a new API instance. Normally you would use <tt>Supreme.api</tt> to create an
    # API instance. If you have to interact with multiple accounts in one process you can
    # instantiate the API class youself.
    #
    # === Options
    #
    # * <tt>:mode</tt> – Holds either :test or :live to signal whether to run in test or live mode. The default value is :test.
    # * <tt>:partner_id</tt> – Your Mollie Partner ID, you can find it under ‘Accountgegevens’ in the settings for your account on mollie.nl.
    #
    # === Example
    #
    #   api = Supreme::API.new(:partner_id => '9834234')
    #   api.test? #=> true
    #   api.banklist
    def initialize(options={})
      self.mode = options[:mode] || options['mode'] || :test
      self.partner_id = options[:partner_id] || options['partner_id']
    end
    
    # Returns true when we're in test mode and false otherwise
    def test?
      self.mode.to_sym == :test
    end
    
    # Requests a list of available banks. Turns a Banklist response.
    # Use Banklist#to_a to get a list of hashes with actual information.
    #
    #   Supreme.api.banklist.to_a # => [{ :id => '1006', :name => 'ABN AMRO Bank' }, …]
    def banklist
      response = get('banklist')
      if response.ok?
        Supreme::Banklist.new(response.body)
      end
    end
    
    # Starts a new payment by sending payment information. It also configures how the iDEAL
    # provider handles payment status information. It returns a Supreme::Transaction response
    # object.
    #
    # === Options
    #
    # Note that the <tt>:description</tt> option has a character limit of 29 characters.
    # Anything after the 29 characters will be silently removed by the API. Note that
    # this description might be handled by ancient bank systems and anything but ASCII
    # characters might be mangled or worse.
    #
    # ==== Required
    #
    # * <tt>:bank_id</tt> – The bank selected by the customer from the <tt>banklist</tt>.
    # * <tt>:amount</tt> – The amount you want to charge in cents (EURO) (ie. €12,99 is 1299)
    # * <tt>:description</tt> – Describe what the payment is for (max 29 characters) (ie. ‘Fluffy Bunny (sku 1234)’ )
    # * <tt>:report_url</tt> – You will receive a GET to this URL with the transaction_id appended in the query (ie. http://example.com/payments?transaction_id=23ad33)
    # * <tt>:return_url</tt> – The customer is redirected to this URL after the payment is complete. The transaction_id is appended as explained for <tt>:report_url</tt>
    #
    # ==== Optional
    #
    # * <tt>:partner_id</tt> – Your Mollie Partner ID, you can find it under ‘Accountgegevens’ in the settings for your account on mollie.nl. Note that the Partner ID is only optional if you've set it either on the API instance or using <tt>Supreme.partner_id</tt>.
    # * <tt>:profile_key</tt> – When your account receives payment from different websites or companies you can set up company profiles. See the Mollie documentation for more information: http://www.mollie.nl/support/documentatie/betaaldiensten/ideal/.
    #
    # === Example
    #
    #   transaction = Supreme.api.fetch({
    #     :bank_id => '0031',
    #     :amount => 1299,
    #     :description => '20 credits for your account',
    #     :report_url => 'http://example.com/payments/ad74hj23',
    #     :return_url => 'http://example.com/payments/ad74hj23/thanks'
    #   })
    #   @purchase.update_attributes!(:transaction_id => transaction.transaction_id)
    #
    # See the Supreme::Transaction class for more information.
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
    
    # Requests the status information for a payment. It returns a Supreme::Status
    # response object.
    #
    # === Options
    #
    # * <tt>:transaction_id</tt> – The transaction ID you received earlier when setting up the transaction.
    #
    # == Example
    #
    #   status = Supreme.api.check(:transaction_id => '482d599bbcc7795727650330ad65fe9b')
    #   if status.paid?
    #     @purchase.paid!
    #   end
    #
    # See the Supreme::Status class for more information.
    def check(options)
      options = options.dup
      options[:partner_id] ||= partner_id
      response = get('check', options)
      if response.ok?
        Supreme::Status.new(response.body)
      end
    end
    
    private
    
    def endpoint
      ENDPOINT.dup
    end
    
    def query(options={})
      options = options.dup
      options[:testmode] = 'true' if test?
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
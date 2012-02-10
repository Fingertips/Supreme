require 'supreme/uri'
require 'supreme/api'
require 'supreme/version'
require 'supreme/response'

module Supreme
  class << self
    # Holds either :test or :live to signal whether to run in test or live mode.
    # The default value is :test.
    attr_accessor :mode
    
    # The partner / client ID given by Mollie.
    #
    # You can find this on the 'Accountgegevens' page.
    attr_accessor :partner_id
  end
  
  def self.test?
    mode.to_sym == :test
  end
  
  # Returns an instance of the API with settings from the Supreme class accessors.
  #
  # If you need to handle multiple accounts in your application you will need to
  # instantiate multiple API instances yourself.
  def self.api
    Supreme::API.new
  end
  
  # Resets the class back to the default settings
  def self.reset!
    self.mode = :test
    self.partner_id = nil
  end
  
  reset!
end
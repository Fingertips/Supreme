require 'supreme/uri'
require 'supreme/api'
require 'supreme/version'
require 'supreme/response'

module Supreme
  class << self
    # Holds either :test or :live to signal whether to run in test or live mode. The default
    # value is :test.
    attr_accessor :mode
    
    # Your Mollie Partner ID, you can find it under ‘Accountgegevens’ in the settings for your account on mollie.nl.
    attr_accessor :partner_id
  end
  
  # Returns an instance of the API with settings from the Supreme class accessors. If you need to handle
  # multiple accounts in your application you will need to instantiate multiple API instances yourself.
  def self.api
    Supreme::API.new(
      :mode => self.mode,
      :partner_id => self.partner_id
    )
  end
  
  # Resets the class back to the default settings
  def self.reset!
    self.mode = :test
    self.partner_id = nil
  end
  
  reset!
  
  private
  
  def self.translate_hash_keys(translation, hash)
    translated = {}
    hash.each do |key, value|
      new_key = translation[key.to_sym] || translation[key.to_s] ||key
      translated[new_key.to_s] = value
    end; translated
  end
end
require 'supreme/api'
require 'supreme/version'

class Supreme
  class << self
    # Holds either :test or :live to signal whether to run in test or live mode
    attr_accessor :mode
  end
  self.mode = :test
  
  # Returns an instance of the API with settings from the Supreme class accessors.
  #
  # If you need to handle multiple accounts in your application you will need to
  # instantiate multiple API instances yourself.
  def self.api
    Supreme::API.new
  end
end
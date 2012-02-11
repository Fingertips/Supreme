$:.unshift File.expand_path('../../lib', __FILE__)

require "rubygems"
require "bundler/setup"

require "supreme"

$DEBUG = !!ENV["DEBUG"]

config_file = File.expand_path('../../config/test.yml', __FILE__)
if File.exist?(config_file)
  require 'yaml'
  config = YAML.load_file(config_file)
  config.each do |key, value|
    puts "Setting :#{key} to `#{value}'"
    Supreme.send("#{key}=", value)
  end
else
  puts "[!] Please copy config/test.yml.example to config/test.yml and set your partner ID to run the remote tests."
  exit(-1)
end

$stdout.sync = true
module Kernel
  def assert(expectation, message=nil)
    if expectation
      $stdout.write('.')
    else
      message ||= "assertion failed"
      puts "FAILURE: #{caller(0)[1]}"
      puts "  #{message}"
      exit -1
    end
  end
end
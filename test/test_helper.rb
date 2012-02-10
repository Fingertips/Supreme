$:.unshift File.expand_path('../../lib', __FILE__)

require "rubygems"
require "bundler/setup"

require "supreme"

require "test/unit"
require 'mocha'
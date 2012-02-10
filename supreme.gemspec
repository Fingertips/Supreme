# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'supreme/version'

Gem::Specification.new do |s|
  s.name     = "kicker"
  s.version  = Supreme::VERSION
  s.date     = Date.today

  s.summary  = "Ruby implementation of the Mollie iDEAL API"
  s.authors  = ["Manfred Stienstra"]
  s.homepage = "http://github.com/Fingertips/Supreme"
  s.email    = %w{ manfred@fngtps.com }

  s.require_paths    = %w{ lib }
  s.files            = Dir['lib/**/*.rb', 'README.md', 'LICENSE']
  s.extra_rdoc_files = %w{ LICENSE README.md }

  s.add_runtime_dependency("nap")
  s.add_runtime_dependency("nokogiri")

  s.add_development_dependency("rake")
  s.add_development_dependency("rdoc") # purely so it doesn't warn about deprecated rake task
  s.add_development_dependency("mocha")
end
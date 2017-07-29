ENV['RACK_ENV'] = 'test'
require "minitest/autorun"

require_relative "../application"

require 'rack/test'
Dir['./test/support/*.rb'].each { |file| require file }

# require "match_json"

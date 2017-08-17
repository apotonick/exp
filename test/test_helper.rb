ENV['RACK_ENV'] = 'test'
require "minitest/autorun"
require 'rack/test'

require_relative "../application"


require "trailblazer/test/assertions"
require "trailblazer/test/operation/assertions"

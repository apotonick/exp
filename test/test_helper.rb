ENV['RACK_ENV'] = 'test'
require "minitest/autorun"
require 'rack/test'

require_relative "../application"


require "trailblazer/test/assertions"
require "trailblazer/test/operation/assertions"

Minitest::Spec.class_eval do
  include Trailblazer::Test::Assertions
  include Trailblazer::Test::Operation::Assertions
  include Trailblazer::Test::Operation::Helper
end

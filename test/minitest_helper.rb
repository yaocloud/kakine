require "bundler/setup"

ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kakine'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'yao/resources/security_group'
require 'yao/resources/security_group_rule'

class Dummy
  def id
    "awesome-id"
  end
end

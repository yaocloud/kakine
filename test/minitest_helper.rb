require "bundler"
Bundler.require

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kakine'
require 'minitest/autorun'
require 'mocha/mini_test'

class Dummy
  def id
    "awesome-id"
  end
end

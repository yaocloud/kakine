require "bundler"
Bundler.require

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kakine'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'fog/openstack/models/network/security_group'
require 'fog/openstack/models/network/security_group_rule'

class Dummy
  def id
    "awesome-id"
  end
end

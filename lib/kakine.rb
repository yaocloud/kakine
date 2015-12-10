require 'yaml'
require 'thor'
require 'json'
require 'yao'
require "kakine/version"
require 'kakine/config'
require 'kakine/cli'
require 'kakine/builder'
require 'kakine/option'
require 'kakine/director'
require 'kakine/adapter'
require 'kakine/adapter/base'
require 'kakine/adapter/real'
require 'kakine/adapter/mock'
require 'kakine/resource'
require 'kakine/resource/openstack'
require 'kakine/resource/yaml'
require 'kakine/security_group'
require 'kakine/security_rule'

module Kakine
  class Error < StandardError; end
  class ConfigureError < Error; end
  class SecurityRuleError < Error; end
end

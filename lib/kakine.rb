require 'yaml'
require 'thor'
require "kakine/version"
require 'kakine/cli'
require 'kakine/builder'
require 'kakine/adapter'
require 'kakine/adapter/real'
require 'kakine/adapter/mock'
require 'kakine/resource'
require 'kakine/resource/openstack'
require 'kakine/resource/yaml'
require 'kakine/security_group'
require 'kakine/security_rule'
require 'kakine/validate'
require 'kakine/errors'

module Kakine
end

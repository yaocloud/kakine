require 'yao'
require 'yaml'

module Kakine
  class Config
    @@auth_url       = nil
    @@tenant         = nil
    @@username       = nil
    @@password       = nil

    def self.setup
      load_config
      load_env
      validate_config
      setup_yao
    end

    private

    def self.load_config
      config_file = File.join(Dir.home, '.kakine')
      return false unless File.exists?(config_file)

      config = YAML.load_file(config_file)

      @@auth_url       = config['auth_url']
      @@tenant         = config['tenant']
      @@username       = config['username']
      @@password       = config['password']
      true
    end

    def self.load_env
      @@auth_url       = ENV['OS_AUTH_URL'] if ENV['OS_AUTH_URL']
      @@tenant         = ENV['OS_TENANT_NAME'] if ENV['OS_TENANT_NAME']
      @@username       = ENV['OS_USERNAME'] if ENV['OS_USERNAME']
      @@password       = ENV['OS_PASSWORD'] if ENV['OS_PASSWORD']
    end

    def self.validate_config
      %w[auth_url tenant username password].each do |conf_item|
        unless class_variable_get("@@#{conf_item}")
          raise "Configuration '#{conf_item}' is missing. Check your ~/.kakine or export OS_#{conf_item.upcase}"
        end
      end
    end

    def self.setup_yao
      Yao.configure do
        auth_url    @@auth_url
        tenant_name @@tenant
        username    @@username
        password    @@password
      end
    end
  end
end

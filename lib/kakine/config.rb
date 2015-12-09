require 'yao'
require 'yaml'

module Kakine
  class Config
    def self.setup
      load_config
      setup_yao
    end

    private

    def self.load_config
      config_file = File.join(Dir.home, '.kakine')
      raise '~/.kakine is missing' unless File.exists?(config_file)

      config = YAML.load_file(config_file)

      %w[auth_url tenant username password].each do |conf_item|
        raise "Configuration '#{conf_item}' is missing. Check your ~/.kakine" unless config[conf_item]
      end

      @@auth_url       = config['auth_url']
      @@tenant         = config['tenant']
      @@username       = config['username']
      @@password       = config['password']
      @@management_url = config['management_url']
      true
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

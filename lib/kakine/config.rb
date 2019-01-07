require 'yao'
require 'yaml'

module Kakine
  class Config
    OS_PARAMS = %w[auth_url username password identity_api_version user_domain_name project_domain_name]

    @@config = {}

    def self.setup
      load_config
      load_env
      validate_config
      setup_yao
    end

    private

    def self.load_config
      config =
        begin
          YAML.load_file(File.join(Dir.home, '.kakine'))
        rescue Errno::ENOENT
          return
        end

      @@config.merge!(config)
    end

    def self.load_env
      OS_PARAMS.each do |param|
        env = "OS_#{param.upcase}"
        @@config[param] = ENV[env] if ENV[env]
      end
    end

    def self.validate_config
      OS_PARAMS.each do |param|
        unless @@config[param]
          raise "Configuration '#{param}' is missing. Check your ~/.kakine or export OS_#{param.upcase}."
        end
      end
    end

    def self.setup_yao
      Yao.configure do
        auth_url             @@config['auth_url']
        tenant_name          Kakine::Option.tenant_name
        username             @@config['username']
        password             @@config['password']
        client_cert          @@config['client_cert']
        client_key           @@config['client_key']
        region_name          @@config['region_name']
        identity_api_version @@config['identity_api_version']
        user_domain_name     @@config['user_domain_name']
        project_domain_name  @@config['project_domain_name']
      end
    end
  end
end

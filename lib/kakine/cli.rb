require 'thor'
require 'fog'
require 'yaml'
require 'hashdiff'
module Kakine
  class CLI < Thor

    option :tenant, type: :string, aliases: '-t'
    desc 'show', 'show Security Groups specified tenant'
    def show
      puts Kakine::Resource.security_groups_hash(options[:tenant]).to_yaml
    end

    option :tenant, type: :string, aliases: "-t"
    option :dryrun, type: :boolean, aliases: "-d"
    option :filename, type: :string, aliases: "-f"
    desc 'apply', "apply local configuration into OpenStack"
    def apply
      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"
      Kakine::Adapter.set_option(options[:dryrun])

      new_security_groups = Kakine::Resource.load_security_group_by_yaml(filename, options[:tenant])
      current_security_groups  = Kakine::Resource.get_current(options[:tenant])

      new_security_groups.each do |new_sg|
      end
    end
  end
end

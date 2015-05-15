require 'thor'
require 'fog'
require 'yaml'
require 'hashdiff'
require 'kakine/operation'

module Kakine
  class CLI < Thor
    include Kakine::Operation
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
      adapter = if options[:dryrun]
        Kakine::Adapter::Mock.new
      else
        Kakine::Adapter::Real.new
      end

      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"

      diffs = HashDiff.diff(Kakine::Resource.security_groups_hash(options[:tenant]), Kakine::Resource.yaml(filename))
      diffs.each do |diff|
        (sg_name, rule_modification) = diff[1].split(/[\.\[]/, 2)

        if sg.is_rule_modify? # foo[2]
          case
          when sg.is_add?
            create_security_rule(sg, adapter)
          when sg.is_delete?
            delete_security_rule(sg,  adapter)
          when "~"
          else
            raise
          end

        else # foo
          case
          when sg.is_add?
            create_security_group(sg, adapter)
            create_security_rule(sg, adapter)
          when sg.is_delete?
            delete_security_group(sg, adapter)
          when "~"
          else
            raise
          end
        end
      end
    end
  end
end

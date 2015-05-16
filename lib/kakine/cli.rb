require 'thor'
require 'fog'
require 'yaml'
require 'hashdiff'
require 'kakine/cli/operation'

module Kakine
  class CLI < Thor
    include Operation

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

      diffs = HashDiff.diff(Kakine::Resource.security_groups_hash(options[:tenant]), Kakine::Resource.yaml(filename)).sort.reverse
      diffs.each do |diff|

        sg = Kakine::SecurityGroup.new(options[:tenant], diff)

        if sg.is_update_rule? # foo[2]
          case
          when sg.is_add?
            create_security_rule(sg, adapter)
          when sg.is_delete?
            delete_security_rule(sg,  adapter)
          when sg.is_update_attr?
            pre_sg = sg.get_prev_instance
            delete_security_rule(pre_sg, adapter)
            create_security_rule(sg, adapter)
          else
            raise
          end
        else # foo
          case
          when sg.is_add?
            security_group_id = create_security_group(sg, adapter)
            create_security_rule(sg, adapter, security_group_id )
          when sg.is_delete?
            delete_security_group(sg, adapter)
          when sg.is_update_attr?
            delete_security_group(sg, adapter)
            security_group_id = create_security_group(sg, adapter)
            create_security_rule(sg, adapter, security_group_id )
          else
            raise
          end
        end
      end
    end
  end
end

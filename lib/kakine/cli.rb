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

      reg_sg = Kakine::Resource.security_groups_hash(options[:tenant])
      diffs = HashDiff.diff(reg_sg, Kakine::Resource.yaml(filename))

      diffs.each do |diff|
        sg_name, rule_modification = *diff[1].scan(/^([\w-]+)(\[\d\])?/)[0]

        (sg_name, rule_modification) = diff[1].split(/[\.\[]/, 2)
        modify_content = Kakine::Resource.format_modify_contents(options[:tenant], sg_name, reg_sg, diff)

        if rule_modification # foo[2]
          security_group = Kakine::Resource.security_group(options[:tenant], sg_name)
          modify_content = set_remote_security_group_id(modify_content, options[:tenant])
          case modify_content["div"]
          when "+"
            adapter.create_rule(security_group.id, modify_content["rules"]["direction"], modify_content["rules"])
          when "-"
            security_group_rule = Kakine::Resource.security_group_rule(security_group, modify_content["rules"])
            adapter.delete_rule(security_group_rule.id)
          else
            raise
          end
        else # foo
          case modify_content["div"]
          when "+"
            create_security_group(sg_name, modify_content, options[:tenant], adapter)

            modify_content["rules"].each do |rule|
              adapter.create_rule(security_group_id, rule["direction"], rule)
            end if modify_content["rules"]
          when "-"
            security_group = Kakine::Resource.security_group(options[:tenant], sg_name)
            adapter.delete_security_group(security_group.id)
          else
            raise
          end
        end
      end
    end
  end
end

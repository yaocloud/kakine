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

        modify_content = Kakine::Resource.format_modify_contents(sg_name, reg_sg, diff)
        if rule_modification # foo[2]
          security_group = Kakine::Resource.security_group(options[:tenant], sg_name)
          if diff[2]["remote_group"]
            remote_security_group = Kakine::Resource.security_group(options[:tenant], diff[2].delete("remote_group"))
            diff[2]["remote_group_id"] = remote_security_group.id
          end
          case diff[0]

          case mod_content["div"]
          when "+"
            mod_content["rules"].merge!({"tenant_id" => Kakine::Resource.tenant(options[:tenant]).id})
            adapter.create_rule(security_group.id, mod_content["rules"]["direction"], mod_content["rules"])
          when "-"
            security_group_rule = Kakine::Resource.security_group_rule(security_group, mod_content["rules"])
            adapter.delete_rule(security_group_rule.id)
          else
            raise
          end
        else # foo
          case mod_content["div"]
          when "+"
            attributes = {name: sg_name, description: mod_content["description"], tenant_id: Kakine::Resource.tenant(options[:tenant]).id}
            security_group_id = adapter.create_security_group(attributes)
            mod_content["rules"].each do |rule|
              rule.merge!({"tenant_id" => Kakine::Resource.tenant(options[:tenant]).id})
              adapter.create_rule(security_group_id, rule["direction"], rule)
            end if mod_content["rules"]
          when "-"
            security_group = Kakine::Resource.security_group(options[:tenant], sg_name)
            adapter.delete_security_group(security_group.id)
            mod_content["rules"].each do |rule|
              if rule["remote_group"]
                remote_security_group = Kakine::Resource.security_group(options[:tenant], rule.delete("remote_group"))
                rule["remote_group_id"] = remote_security_group.id
              end
              adapter.create_rule(security_group_id, rule["direction"], rule)
            end if mod_content["rules"]
          else
            raise
          end
        end
      end
    end
  end
end

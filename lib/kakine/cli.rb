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
      adapter = Kakine::Adapter::Mock.new
      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"
      diffs = HashDiff.diff(Kakine::Resource.security_groups_hash(options[:tenant]), YAML.load_file(filename).to_hash)

      diffs.each do |diff|
        sg_name, rule_modification = *diff[1].scan(/^([\w-]+)(\[\d\])?/)[0]

        if rule_modification # foo[2]
          security_group = Kakine::Resource.security_groups_on_tenant(options[:tenant]).detect{|sg| sg.name == sg_name.to_s}
          case diff[0]
          when "+"
            diff[2].merge!({"ethertype" => "IPv4", "teanant_id" => Kakine::Resource.tenant(options[:tenant]).id})
            adapter.create_rule(security_group.id, diff[2]["direction"], diff[2])
          when "-"
            security_group_rule = security_group.security_group_rules.detect do |sg|
              if diff[2]["port"]
                diff[2]["port_range_max"] = diff[2]["port_range_min"] = diff[2]["port"]
              end

              sg.direction == diff[2]["direction"] &&
              sg.protocol == diff[2]["protocol"] &&
              sg.port_range_max == diff[2]["port_range_max"] &&
              sg.port_range_min == diff[2]["port_range_min"] &&
              sg.remote_ip_prefix == diff[2]["remote_ip"] &&
              sg.remote_group_id == diff[2]["remote_group_id"]
            end
            adapter.delete_rule(security_group_rule.id)
          else
            raise
          end
        else # foo
          case diff[0]
          when "+"
            attributes = {name: sg_name, description: "", tenant_id: Kakine::Resource.tenant(options[:tenant]).id}
            security_group_id = adapter.create_security_group(attributes)
            diff[2].each do |rule|
              rule.merge!({"ethertype" => "IPv4", "teanant_id" => Kakine::Resource.tenant(options[:tenant]).id})
              adapter.create_rule(security_group_id, rule["direction"], rule)
            end
          when "-"
            security_group = Kakine::Resource.security_groups_on_tenant(options[:tenant]).detect{|sg| sg.name == sg_name.to_s}
            adapter.delete_security_group(security_group.id)
          else
            raise
          end
        end
      end
    end
  end
end

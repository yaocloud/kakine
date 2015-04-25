require 'thor'
require 'fog'
require 'yaml'
require 'hashdiff'

module Kakine
  class CLI < Thor
    option :tenant, type: :string, aliases: '-t'
    desc 'show', 'show Security Groups specified tenant'
    def show
      puts security_groups(options[:tenant]).to_yaml
    end

    option :tenant, type: :string, aliases: "-t"
    option :dryrun, type: :boolean, aliases: "-d"
    option :filename, type: :string, aliases: "-f"
    desc 'apply', "apply local configuration into OpenStack"
    def apply
      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"
      diffs = HashDiff.diff(security_groups(options[:tenant]), YAML.load_file(filename).to_hash)

      diffs.each do |diff|
        sg_name, rule_modification = *diff[1].scan(/^([\w-]+)(\[\d\])?/)[0]

        if rule_modification # foo[2]
          security_group = security_groups_on_tenant(options[:tenant]).detect{|sg| sg.name == sg_name.to_s}
          case diff[0]
          when "+"
            attributes = {"ethertype" => "IPv4", "teanant_id" => tenant(options[:tenant]).id}
            if diff[2]["port"]
              attributes["port_range_max"] = attributes["port_range_min"] = diff[2].delete("port")
            end
            attributes["remote_ip_prefix"] = diff[2].delete("remote_ip")
            diff[2].delete("direction")
            attributes.merge!(diff[2])
            puts "Create Rule: #{attributes}"
            # Fog::Network[:openstack].create_security_group_rule(security_group.id, diff[2]["direction"], attributes)
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
            puts "Delete Rule: #{security_group_rule}"
            # Fog::Network[:openstack].delete_security_group_rule(security_group_rule.id)
          else
            raise
          end
        else # foo
          case diff[0]
          when "+"
            puts "Create Security Group: #{sg_name}"
            # data = {name: sg_name, description: "", tenant_id: tenant(options[:tenant]).id}
            # response = Fog::Network[:openstack].create_security_group(security_group.name, )
            diff[2].each do |rule|
              attributes = {"ethertype" => "IPv4", "teanant_id" => tenant(options[:tenant]).id}
              if diff[2]["port"]
                attributes["port_range_max"] = attributes["port_range_min"] = diff[2].delete("port")
              end
              attributes["remote_ip_prefix"] = rule.delete("remote_ip")
              rule.delete("direction")
              attributes.merge!(rule)
              puts "Create Rule: #{attributes}"
              # Fog::Network[:openstack].create_security_group_rule(response.data["body"]["security_group_id"], rule["direction"], attributes)
            end
          when "-"
            security_group = security_groups_on_tenant(options[:tenant]).detect{|sg| sg.name == sg_name.to_s}
            puts "Delete Security Group: #{security_group.name}"
            # Fog::Network[:openstack].delete_security_group(security_group.id)
          else
            raise
          end
        end
      end
    end

    private

    def security_groups(tenant_name)
      sg_hash = {}

      security_groups_on_tenant(tenant_name).each do |sg|
        sg_hash[sg.name] = format_security_group(sg)
      end

      sg_hash
    end

    def security_groups_on_tenant(tenant_name)
      security_groups = Fog::Network[:openstack].security_groups
      security_groups.select{|sg| sg.tenant_id == tenant(tenant_name).id}
    end

    def tenant(tenant_name)
      tenants = Fog::Identity[:openstack].tenants
      tenants.detect{|t| t.name == tenant_name}
    end

    def format_security_group(security_group)
      rules = []

      security_group.security_group_rules.each do |rule|
        rule_hash = {}

        rule_hash["direction"] = rule.direction
        rule_hash["protocol"] = rule.protocol

        if rule.port_range_max == rule.port_range_min
          rule_hash["port"] = rule.port_range_max
        else
          rule_hash["port_range_max"] = rule.port_range_max
          rule_hash["port_range_min"] = rule.port_range_min
        end

        if rule.remote_group_id
          response = Fog::Network[:openstack].get_security_group(rule.remote_group_id)
          rule_hash["remote_group"] = response.data[:body]["security_group"]["name"]
        else
          rule_hash["remote_ip"] = rule.remote_ip_prefix
        end

        rules << rule_hash
      end

      rules
    end
  end
end

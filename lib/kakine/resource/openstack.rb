module Kakine
  class Resource
    class OpenStack
      class << self
        def load_security_group
          security_groups_hash.map do |sg|
            Kakine::SecurityGroup.new(Kakine::Options.tenant_name, sg)
          end
        end

        def tenant(tenant_name)
          @@tenant ||= Kakine::Adapter.instance.tenants.detect{|t| t.name == tenant_name}
        end

        def security_group(tenant_name, security_group_name)
          security_groups_on_tenant(tenant_name).detect{|sg| sg.name == security_group_name}
        end

        def security_groups_on_tenant(tenant_name)
          Kakine::Adapter.instance.security_groups.select { |sg| sg.tenant_id == tenant(tenant_name).id }
        end

        def security_groups_hash
          sg_hash = Hash.new { |h,k| h[k] = {} }

          security_groups_on_tenant(Kakine::Options.tenant_name).each do |sg|
            sg_hash[sg.name]["rules"]       = format_security_group(sg)
            sg_hash[sg.name]["id"]          = sg.id
            sg_hash[sg.name]["description"] = sg.description
          end
          sg_hash
        end

        def format_security_group(security_group)
          security_group.security_group_rules.map do |rule|
            rule_hash = {}
            rule_hash["id"]        = rule.id
            rule_hash["direction"] = rule.direction
            rule_hash["protocol"]  = rule.protocol
            rule_hash["ethertype"] = rule.ethertype
            rule_hash.merge!(port_hash(rule))
            rule_hash.merge!(remote_hash(rule))
          end
        end

        def port_hash(rule)
          case
          when rule.protocol == "icmp"
            { "type" => rule.port_range_min, "code" => rule.port_range_max }
          when rule.port_range_max == rule.port_range_min
            { "port" => rule.port_range_max }
          else
            { "port_range_min" => rule.port_range_min, "port_range_max" => rule.port_range_max }
          end
        end

        def remote_hash(rule)
          case
          when rule.remote_group_id
            response = Kakine::Adapter.instance.get_security_group(rule.remote_group_id)
            { "remote_group" => response.data[:body]["security_group"]["name"] }
          else
            { "remote_ip" => rule.remote_ip_prefix }
          end
        end
      end
    end
  end
end

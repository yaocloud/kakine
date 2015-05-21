module Kakine
  class Resource
    class << self
      def load_security_group_by_yaml(filename, tenant_name)
        register_sg = []
        yaml(filename).each do |sg|
          register_sg << Kakine::SecurityGroup.new(tenant_name, sg)
        end
        register_sg
      end

      def get_current(tenant_name)
        current = []
        Kakine::Resource.security_groups_hash(tenant_name).each do |sg|
          current << Kakine::SecurityGroup.new(tenant_name, sg)
        end
        current
      end

      def yaml(filename)
        YAML.load_file(filename).to_hash
      end

      def tenant(tenant_name)
        @tenant ||= Fog::Identity[:openstack].tenants.detect{|t| t.name == tenant_name}
      end

      def security_group(tenant_name, security_group_name)
        security_groups_on_tenant(tenant_name).detect{|sg| sg.name == security_group_name}
      end

      def security_group_rule(security_group, attributes)
        security_group.security_group_rules.detect do |sg|

          sg.direction == attributes.direction &&
          sg.protocol == attributes.protocol &&
          sg.port_range_max == attributes.port_range_max &&
          sg.port_range_min == attributes.port_range_min &&
          sg.ethertype == attributes.ethertype &&
          (
            (
              attributes.remote_group_id.nil? &&
              sg.remote_ip_prefix == attributes.remote_ip
            ) ||
            (
              attributes.remote_ip.nil? &&
              sg.remote_group_id == attributes.remote_group_id
            )
          )
        end
      end

      def security_groups_on_tenant(tenant_name)
        Fog::Network[:openstack].security_groups.select{|sg| sg.tenant_id == tenant(tenant_name).id}
      end

      def security_groups_hash(tenant_name)
        sg_hash = Hash.new { |h,k| h[k] = {} }

        security_groups_on_tenant(tenant_name).each do |sg|
          sg_hash[sg.name]["rules"]       = format_security_group(sg)
          sg_hash[sg.name]["description"] = sg.description
        end
        sg_hash
      end

      def format_security_group(security_group)
        rules = []

        security_group.security_group_rules.each do |rule|
          rule_hash = {}
          rule_hash["direction"] = rule.direction
          rule_hash["protocol"]  = rule.protocol
          rule_hash["ethertype"] = rule.ethertype

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
end

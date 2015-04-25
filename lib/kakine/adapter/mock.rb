module Kakine
  class Adapter
    class Mock
      def create_rule(security_group_id, direction, attributes)
        attributes.delete("direction")
        if attributes["port"]
          attributes["port_range_max"] = attributes["port_range_min"] = attributes.delete("port")
        end
        attributes["remote_ip_prefix"] = attributes.delete("remote_ip")
        puts "Create Rule: #{security_group_id} - #{direction}: #{attributes}"
      end

      def delete_rule(security_group_rule_id)
        puts "Delete Rule: #{security_group_rule_id}"
      end

      def create_security_group(attributes)
        puts "Create Security Group: #{attributes}"
        tenant = Fog::Identity[:openstack].get_tenant(attributes["tenant_id"])
        Kakine::Resource.security_group(tenant.name, attributes["name"])
      end

      def delete_security_group(security_group_id)
        puts "Delete Security Group: #{security_group_id}"
      end
    end
  end
end

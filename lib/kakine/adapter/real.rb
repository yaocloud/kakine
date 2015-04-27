module Kakine
  class Adapter
    class Real
      def create_rule(security_group_id, direction, attributes)
        attributes.delete("direction")
        if attributes["port"]
          attributes["port_range_max"] = attributes["port_range_min"] = attributes.delete("port")
        end
        if attributes["remote_ip"]
          attributes["remote_ip_prefix"] = attributes.delete("remote_ip")
        end

        data = {}
        attributes.each{|k,v| data[k.to_sym] = v}
        Fog::Network[:openstack].create_security_group_rule(security_group_id, direction, data)
      end

      def delete_rule(security_group_rule_id)
        Fog::Network[:openstack].delete_security_group_rule(security_group_rule_id)
      end

      def create_security_group(attributes)
        data = {}
        attributes.each{|k,v| data[k.to_sym] = v}
        response = Fog::Network[:openstack].create_security_group(data)
        response.data[:body]["security_group"]["id"]
      end

      def delete_security_group(security_group_id)
        Fog::Network[:openstack].delete_security_group(security_group_id)
      end
    end
  end
end

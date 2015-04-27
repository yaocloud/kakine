module Kakine
  class Adapter
    class Mock
      def create_rule(security_group_id, direction, attributes)
        attributes.delete("direction")
        if attributes["port"]
          attributes["port_range_max"] = attributes["port_range_min"] = attributes.delete("port")
        end
        attributes["remote_ip_prefix"] = attributes.delete("remote_ip")

        data = {}
        attributes.each{|k,v| data[k.to_sym] = v}
        puts "Create Rule: #{security_group_id} - #{direction}: #{attributes}"
      end

      def delete_rule(security_group_rule_id)
        puts "Delete Rule: #{security_group_rule_id}"
      end

      def create_security_group(attributes)
        data = {}
        attributes.each{|k,v| data[k.to_sym] = v}
        puts "Create Security Group: #{data}"
        "[Mock] #{attributes[:name]} ID"
      end

      def delete_security_group(security_group_id)
        puts "Delete Security Group: #{security_group_id}"
      end
    end
  end
end

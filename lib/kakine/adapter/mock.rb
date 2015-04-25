module Kakine
  class Adapter
    class Mock
      def create_rule(security_group_id, direction, attributes)
        puts "Create Rule: #{security_group_id} - #{direction}: #{attributes}"
        # Fog::Network[:openstack].create_security_group_rule(security_group_id, direction, attributes)
      end

      def delete_rule(security_group_id)
        puts "Delete Rule: #{security_group_rule_id}"
        # Fog::Network[:openstack].delete_security_group_rule(security_group_rule_id)
      end

      def create_security_group(attributes)
        puts "Create Security Group: #{attributes}"
        # response = Fog::Network[:openstack].create_security_group(attributes)
      end

      def delete_security_group(security_group_id)
        puts "Delete Security Group: #{security_group_id}"
        # Fog::Network[:openstack].delete_security_group(security_group_id)
      end
    end
  end
end

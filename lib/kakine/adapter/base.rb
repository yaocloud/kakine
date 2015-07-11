module Kakine
  class Adapter
    module Base
      def tenants
        Fog::Identity[:openstack].tenants
      end

      def security_groups
        Fog::Network[:openstack].security_groups
      end

      def get_security_group
        Fog::Network[:openstack].get_security_group
      end
    end
  end
end

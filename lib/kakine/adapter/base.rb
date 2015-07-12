module Kakine
  class Adapter
    module Base
      def tenants
        Fog::Identity[:openstack].tenants
      end

      def security_groups
        Fog::Network[:openstack].security_groups
      end

      def get_security_group(remote_group_id)
        Fog::Network[:openstack].get_security_group(remote_group_id)
      end
    end
  end
end

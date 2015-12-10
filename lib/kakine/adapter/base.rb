module Kakine
  class Adapter
    module Base
      def tenants
        Yao::Tenant.list
      end

      def security_groups
        Yao::SecurityGroup.list
      end

      def get_security_group(remote_group_id)
        Yao::SecurityGroup.get(remote_group_id)
      end
    end
  end
end

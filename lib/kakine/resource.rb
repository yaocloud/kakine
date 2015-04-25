module Kakine
  class Resource
    class << self
      def tenant(tenant_name)
        tenants = Fog::Identity[:openstack].tenants
        tenants.detect{|t| t.name == tenant_name}
      end

      def security_groups_on_tenant(tenant_name)
        security_groups = Fog::Network[:openstack].security_groups
        security_groups.select{|sg| sg.tenant_id == tenant(tenant_name).id}
      end
    end
  end
end

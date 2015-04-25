module Kakine
  class Resource
    class << self
      def tenant(tenant_name)
        tenants = Fog::Identity[:openstack].tenants
        tenants.detect{|t| t.name == tenant_name}
      end
    end
  end
end

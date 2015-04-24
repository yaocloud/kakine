require 'thor'
require 'fog'

module Kakine
  class CLI < Thor
    option :tenant, type: :string, aliases: '-t'
    desc 'show', 'show Security Groups specified tenant'
    def show
      security_groups = Fog::Network[:openstack].security_groups

      tenants = Fog::Identity[:openstack].tenants
      tenant = tenants.detect{|t| t.name == options[:tenant]}

      security_groups_on_tenant = security_groups.select{|sg| sg.tenant_id == tenant.id}
      pp security_groups_on_tenant
    end
  end
end

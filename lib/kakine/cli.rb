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
      security_groups_on_tenant.each do |sg|
        puts format_security_group(sg)
      end
    end

    private

    def format_security_group(security_group)
      sg_hash = {}

      sg_hash[:name] = security_group.name

      sg_hash.to_json
    end
  end
end

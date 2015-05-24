module Kakine
  class Operation

    def initialize
      @adapter = Kakine::Adapter.get_instance
    end

    def create_security_group(sg)
      attributes = {name: sg.name, description: sg.description, tenant_id: sg.tenant_id}
      security_group_id = @adapter.create_security_group(attributes)

      #delete default rule
      delete_sg = sg.get_default_rule_instance
      delete_sg.rules each { |rule| rule.unregister! } unless @adapter.instance_of?(Kakine::Adapter::Mock)
      security_group_id
    end

    def delete_security_group(sg)
      security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
      @adapter.delete_security_group(security_group.id)
    end

    def create_security_rule(tenant_name, sg_name, rule)
      security_group_id = if @adapter.instance_of?(Kakine::Adapter::Mock)
        "[Mock] #{sg_name} ID"
      else
        Kakine::Resource.security_group(tenant_name, sg_name).id
      end
      @adapter.create_rule(security_group_id, rule.direction, rule)
    end

    def delete_security_rule(tenant_name, sg_name, rule)
      security_group = Kakine::Resource.security_group(tenant_name, sg_name)
      security_group_rule = Kakine::Resource.security_group_rule(security_group, rule)
      @adapter.delete_rule(security_group_rule.id)
    end
  end
end

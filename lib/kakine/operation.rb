module Kakine
  class Operation
    def initialize
      @adapter = Kakine::Resource.get_adapter
    end

    def create_security_group(sg)
      attributes = {name: sg.name, description: sg.description, tenant_id: sg.tenant_id}
      security_group_id = @adapter.create_security_group(attributes)

      #delete default rule
      delete_sg = sg.clone
      delete_sg.set_default_rules

      delete_security_rule(delete_sg) unless @adapter.instance_of?(Kakine::Adapter::Mock)
      security_group_id
    end

    def delete_security_group(sg)
      security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
      @adapter.delete_security_group(security_group.id)
    end

    def create_security_rule(rule)
      security_group = Kakine::Resource.security_group(rule.tenant_name, rule.sg_name)
      security_group_id = security_group.id
      @adapter.create_rule(security_group_id, rule.direction, rule)
    end

    def delete_security_rule(sg)
      security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
      sg.rules.each do |rule|
        security_group_rule = Kakine::Resource.security_group_rule(security_group, rule)
        @adapter.delete_rule(security_group_rule.id)
      end if sg.has_rules?
    end
  end
end

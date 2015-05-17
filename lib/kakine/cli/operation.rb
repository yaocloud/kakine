module Kakine
  class CLI < Thor
    module Operation
      def create_security_group(sg, adapter)
        attributes = {name: sg.name, description: sg.description, tenant_id: sg.tenant_id}
        security_group_id = adapter.create_security_group(attributes)

        #delete default rule
        delete_sg = sg.clone
        delete_sg.set_default_rules

        delete_security_rule(delete_sg, adapter) unless adapter.instance_of?(Kakine::Adapter::Mock)
        security_group_id
      end

      def delete_security_group(sg, adapter)
        security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
        adapter.delete_security_group(security_group.id)
      end

      def create_security_rule(sg, adapter, security_group_id=nil)
        if security_group_id.nil?
          security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
          security_group_id = security_group.id
        end
        sg.rules.each do |rule|
          adapter.create_rule(security_group_id, rule["direction"], rule)
        end if sg.has_rules?
      end

      def delete_security_rule(sg, adapter)
        security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
        sg.rules.each do |rule|
          security_group_rule = Kakine::Resource.security_group_rule(security_group, rule)
          adapter.delete_rule(security_group_rule.id)
        end if sg.has_rules?
      end
    end
  end
end

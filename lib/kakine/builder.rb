module Kakine
  class Builder 
    class << self
      def adapter
        @@adapter ||= Kakine::Adapter.instance
      end

      def create_security_group(sg)
        attributes = {name: sg.name, description: sg.description, tenant_id: sg.tenant_id}
        security_group_id = adapter.create_security_group(attributes)

        #delete default rule
        sg.get_default_rule_instance.rules.each do |rule| 
          Kakine::Builder.delete_security_rule(rule.tenant_name, sg.name, rule)
        end unless adapter.instance_of?(Kakine::Adapter::Mock)
        security_group_id
      end

      def delete_security_group(sg)
        security_group = Kakine::Resource.get(:openstack).security_group(sg.tenant_name, sg.name)
        adapter.delete_security_group(security_group.id)
      end

      def create_security_rule(tenant_name, sg_name, rule)
        security_group_id = if adapter.instance_of?(Kakine::Adapter::Mock)
          "[Mock] #{sg_name} ID"
        else
          Kakine::Resource.get(:openstack).security_group(tenant_name, sg_name).id
        end
        adapter.create_rule(security_group_id, rule.direction, rule)
      end

      def delete_security_rule(tenant_name, sg_name, rule)
        security_group = Kakine::Resource.get(:openstack).security_group(tenant_name, sg_name)
        security_group_rule = Kakine::Resource.get(:openstack).security_group_rule(security_group, rule)
        adapter.delete_rule(security_group_rule.id)
      end

      def convergence_security_group(new, old)
        if new.description != old.description
          Kakine::Builder.delete_security_group(old)
          Kakine::Builder.create_security_group(new)
          new.rules.each do |rule|
            Kakine::Builder.create_security_rule(new.tenant_name, new.name, rule)
          end if new.has_rules?
        else
          old.rules.each do |rule|
            Kakine::Builder.delete_security_rule(new.tenant_name, new.name, rule) unless new.find_by_rule(rule)
          end
          new.rules.each do |rule|
            unless old.find_by_rule(rule)
              Kakine::Builder.create_security_rule(new.tenant_name, new.name, rule)
            end
          end
        end
      end
    end
  end
end

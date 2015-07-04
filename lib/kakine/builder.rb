module Kakine
  class Builder 
    class << self
      def create_security_group(sg)
        attributes = {name: sg.name, description: sg.description, tenant_id: sg.tenant_id}
        security_group_id = Kakine::Adapter.instance.create_security_group(attributes)
        delete_default_security_rule(sg.tenant_name, sg.name)
        security_group_id
      end

      def delete_security_group(sg)
        security_group = Kakine::Resource.get(:openstack).security_group(sg.tenant_name, sg.name)
        Kakine::Adapter.instance.delete_security_group(security_group.id)
      end

      def create_security_rule(tenant_name, sg_name, rule)
        security_group_id = Kakine::Resource.get(:openstack).security_group(tenant_name, sg_name).id
        Kakine::Adapter.instance.create_rule(security_group_id, rule.direction, rule)
      end

      def delete_security_rule(tenant_name, sg_name, rule)
        security_group = Kakine::Resource.get(:openstack).security_group(tenant_name, sg_name)
        security_group_rule = Kakine::Resource.get(:openstack).security_group_rule(security_group, rule)
        Kakine::Adapter.instance.delete_rule(security_group_rule.id)
      end

      def delete_default_security_rule(tenant_name, sg_name)
        %w(IPv4 IPv6).map { |v| {"direction"=>"egress", "protocol" => "", "port" => "", "remote_ip" => "", "ethertype"=>v } }.
        map{ |rule| SecurityRule.new(rule, tenant_name, sg_name) }.each do |rule|
          delete_security_rule(tenant_name, sg_name, rule)
        end
      end

      def convergence_security_group(new_sg, old_sg)
        if new_sg.description != old_sg.description
          recreate_security_group(new_sg, old_sg)
        else
          delete_not_exists_rule(new_sg, old_sg)
          create_new_rule(new_sg, old_sg)
        end
      end

      def recreate_security_group(new_sg, old_sg)
        delete_security_group(old_sg)
        create_security_group(new_sg)
        new_sg.rules.each do |rule|
          create_security_rule(new_sg.tenant_name, new_sg.name, rule)
        end if new_sg.has_rules?
      end

      def delete_not_exists_rule(new_sg, old_sg)
        old_sg.rules.each do |rule|
          delete_security_rule(new_sg.tenant_name, new_sg.name, rule) unless new_sg.find_by_rule(rule)
        end
      end

      def create_new_rule(new_sg, old_sg)
        new_sg.rules.each do |rule|
          unless old_sg.find_by_rule(rule)
            create_security_rule(new_sg.tenant_name, new_sg.name, rule)
          end
        end
      end
    end
  end
end

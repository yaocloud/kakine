module Kakine
  module Operation
    def create_security_group(sg, adapter)
      attributes = {name: sg.name, description: sg.description, tenant_id: sg.tenant_id}
      security_group_id = adapter.create_security_group(attributes)

      #delete default rule
      delete_sg = sg.clone
      delete_sg.unset_security_rules
      ["IPv4", "IPv6"].each do |ip|
          delete_sg.rules << {"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>ip}
      end

      delete_security_rule(delete_sg, adapter)
      security_group_id
    end

    def delete_security_group(sg, adapter)
      security_group = Kakine::Resource.security_group(sg.tenant_name, sg.name)
      adapter.delete_security_group(security_group.id)
    end

    def create_security_rule(sg, adapter)
      security_group      = Kakine::Resource.security_group(sg.tenant_name, sg.name)
      sg.rules.each do |rule|
        adapter.create_rule(security_group.id, rule["direction"], rule)
      end if sg.has_rules?
    end

    def delete_security_rule(sg, adapter)
      security_group      = Kakine::Resource.security_group(sg.tenant_name, sg.name)
      sg.rules.each do |rule|
        security_group_rule = Kakine::Resource.security_group_rule(security_group, rule)
        adapter.delete_rule(security_group_rule.id)
      end if sg.has_rules?
    end
  end
end

module Kakine
  module Operation
    def set_remote_security_group_id(modify_content, tenant)
      modify_content["rules"].each do |rule|
        unless rule['remote_group'].nil?
          remote_security_group = Kakine::Resource.security_group(tenant, rule.delete("remote_group"))
          rule["remote_group_id"] = remote_security_group.id
        end
      end if modify_content["rules"].detect {|v| v.size > 0}
      modify_content
    end

    def create_security_group(sg_name ,modify_content, tenant, adapter)
      attributes = {name: sg_name, description: modify_content["description"], tenant_id: Kakine::Resource.tenant(tenant).id}
      security_group_id = adapter.create_security_group(attributes)

      #delete default rule
      r = { "rules" => [] }
      ["IPv4", "IPv6"].each do |ip|
          r["rules"] << {"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>ip}
      end
      delete_security_rule(sg_name, r, tenant, adapter)
      security_group_id
    end

    def delete_security_group(sg_name , tenant, adapter)
      security_group = Kakine::Resource.security_group(options[:tenant], sg_name)
      adapter.delete_security_group(security_group.id)
    end

    def create_security_rule(sg_name, modify_content, tenant, adapter)
      security_group      = Kakine::Resource.security_group(tenant, sg_name)
      modify_content["rules"].each do |rule|
        adapter.create_rule(security_group.id, rule["direction"], rule)
      end if modify_content["rules"].detect {|v| v.size > 0}
    end

    def delete_security_rule(sg_name, modify_content, tenant, adapter)
      security_group      = Kakine::Resource.security_group(tenant, sg_name)
      modify_content["rules"].each do |rule|
        security_group_rule = Kakine::Resource.security_group_rule(security_group, rule)
        adapter.delete_rule(security_group_rule.id)
      end if modify_content["rules"].detect {|v| v.size > 0}
    end
  end
end

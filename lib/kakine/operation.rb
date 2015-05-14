module Kakine
  module Operation
    def set_remote_security_group_id(modify_content, tenant)
      modify_content["rules"].each do |rule|
        unless rule['remote_group'].nil?
          remote_security_group = Kakine::Resource.security_group(tenant, rule.delete("remote_group"))
          rule["remote_group_id"] = remote_security_group.id
        end
      end unless modify_content["rules"].nil?
      modify_content
    end

    def create_security_group(sg_name ,modify_content, tenant, adapter)
      attributes = {name: sg_name, description: modify_content["description"], tenant_id: Kakine::Resource.tenant(tenant).id}
      security_group_id = adapter.create_security_group(attributes)

      #delete default rule
      security_group      = Kakine::Resource.security_group(tenant, sg_name)
      ["IPv4", "IPv6"].each do |ip|
        security_group_rule = Kakine::Resource.security_group_rule(
          security_group,
          {"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>ip},
        )
        adapter.delete_rule(security_group_rule.id)
      end
      security_group_id
    end
  end
end

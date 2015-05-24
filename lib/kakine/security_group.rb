module Kakine
  class SecurityGroup
    attr_reader :name, :tenant_id, :tenant_name, :description, :rules

    def initialize(tenant_name, parameter, adapter)
      @name = parameter[0]
      @tenant_name = tenant_name
      @tenant_id = Kakine::Resource.tenant(tenant_name).id
      @description = parameter[1]["description"] || ""

      @rules = parameter[1]["rules"].inject([]) do |rules,rule|
        rules << SecurityRule.new(rule, @tenant_name)
        rules
      end unless parameter[1]["rules"].nil?

      @operation = Kakine::Operation.new
    end

    def register!
      security_group_id = @operation.create_security_group(self)
      operation.create_security_rule(self, security_group_id)
    end

    def has_rules?
      @rules.detect {|v| !v.nil?}
    end

    #def set_default_rules
    #  unset_security_rules
    #  ["IPv4", "IPv6"].each do |ip|
    #      add_security_rules({"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>ip})
    #  end
    #end
  end
end

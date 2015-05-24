module Kakine
  class SecurityGroup
    attr_reader :name, :tenant_id, :tenant_name, :description, :rules

    def initialize(tenant_name, parameter, adapter)
      @name = parameter[0]
      @tenant_name = tenant_name
      @tenant_id = Kakine::Resource.tenant(tenant_name).id
      @description = parameter[1]["description"] || ""

      @rules = parameter[1]["rules"].inject([]) do |rules,rule|
        rules << SecurityRule.new(rule, @teant_name, @name)
        rules
      end unless parameter[1]["rules"].nil?

      @operation = Kakine::Operation.new
    end

    def initialize_copy(obj)
      @rules = Marshal.load(Marshal.dump(obj.rules))
    end

    def register!
      @operation.create_security_group(self)
      @rules.each do |rule|
        rule.register!
      end if has_rules?
    end

    def unregister!
      @operation.delete_security_group(self)
    end

    def has_rules?
      @rules.detect {|v| !v.nil?}
    end

    def get_default_rule_instance
      default_sg = self.clone
      default_sg.set_default_rules
      default_sg
    end

    def set_default_rule!
      @rules = [{"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>"IPv4"},
      {"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>"IPv6"}].inject([]) do |inc_rule,rule|
        inc_rule << SecurityRule.new(rule, @tenant_name, @name)
        inc_rule
      end
    end
  end
end

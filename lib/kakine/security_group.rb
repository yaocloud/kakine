module Kakine
  class SecurityGroup
    attr_reader :target_object_name, :name, :transaction_type, :tenant_id, :tenant_name, :description, :rules, :prev_rules

    def initialize(tenant_name, diff)
      unset_security_rules
      Kakine::DiffParser.parse_parameters(tenant_name, diff).each do|k,v|
        instance_variable_set(eval(":@#{k.to_s}"), v)
      end
      set_remote_security_group_id
    end

    def initialize_copy(obj)
      @rules = Marshal.load(Marshal.dump(obj.rules))
      @prev_rules = Marshal.load(Marshal.dump(obj.prev_rules))
      unset_security_rules
    end

    def has_rules?
      @rules.detect {|v| !v.nil? && v.size > 0}
    end

    def add?
      @transaction_type == "+"
    end

    def delete?
      @transaction_type == "-"
    end

    def update_attr?
      @transaction_type == "~" && !@rules.empty?
    end

    def delete_all_rules?
      @transaction_type == "~" && @rules.empty? 
    end

    def update_rule?
      !@target_object_name.split(/[\[]/, 2)[1].nil?
    end

    def get_prev_instance
      prev_sg = self.clone
      prev_sg.add_security_rules(@prev_rules)
      prev_sg
    end

    def set_default_rules
      unset_security_rules
      ["IPv4", "IPv6"].each do |ip|
          add_security_rules({"direction"=>"egress", "protocol"=>nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>ip})
      end
    end

    def add_security_rules(rule)
      case
        when rule.instance_of?(Array)
          @rules = rule
        when rule.instance_of?(Hash)
          @rules << rule
      end
    end

    private

    def unset_security_rules
      @rules = []
    end

    def set_remote_security_group_id
      @rules.each do |rule|
        unless rule['remote_group'].nil?
          remote_security_group = Kakine::Resource.security_group(@tenant_name, rule.delete("remote_group"))
          rule["remote_group_id"] = remote_security_group.id
        end
      end if has_rules?
    end
  end
end

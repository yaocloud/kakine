module Kakine
  class SecurityGroup
    attr_accessor :description, :tenant_name
    def initialize(tenant_name, diff)
      @diff         = diff
      @tenant_name  = tenant_name
      tenant_name  = tenant_name
      registered_sg = Kakine::Resource.security_groups_hash(@tenant_name)
      unset_security_rules

      if ["+", "-"].include?(type)
        # ["+", "sg_name", {"rules"=>[{"direction"=>"egress" ~ }]}]
        if diff[2] && diff[2]["rules"]
          description  = diff[2]["description"]
          add_security_rules(diff[2]["rules"])
        # ["-", "sg_namerules[0]", {"direction"=>"egress" ~ }]
        elsif diff[2]
          description = registered_sg[name]["description"]
          add_security_rules(diff[2])
        end
        # ["+", "sg_name", nil]
        # unmatch is no rule sg
      else
        # ["~", "sg_name.description", "before_value", "after_value"]
        if m = diff[1].match(/^([\w-]+)\.([\w]+)$/)
          description = diff[3]
          add_security_rules(registered_sg[name]["rules"])
        # ["~", "sg_name.rules[0].port", before_value, after_value]
        elsif m = diff[1].match(/^([\w-]+).([\w]+)\[(\d)\].([\w]+)$/)
          description    = registered_sg[name]["description"]
          registered_sg[name]["rules"][m[3].to_i][m[4]] = diff[3]
          add_security_rules(registered_sg[name]["rules"][m[3].to_i])
        else
          raise
        end
      end
      set_remote_security_group_id
    end

    def initialize_copy(obj)
      unset_security_rules
    end

    def type
      @diff[0]
    end

    def name
      @diff[1].split(/[\.\[]/, 2)[0]
    end

    def tenant_id
      @tenant_id ||= Kakine::Resource.tenant(tenant_name).id
    end

    def get_security_rules
      @rules
    end

    def add_security_rules(rule)
      case
        when rule.instance_of?(Array)
          @rules = rule
        when rule.instance_of?(Hash)
          @rules << rule
        else
          raise
      end
    end

    def unset_security_rules
      @rules = []
    end

    def has_rules?
      @rules.detect {|v| !v.nil? && v.size > 0}
    end

    def is_add?
      type == "+"
    end

    def is_delete?
      type == "-"
    end

    def is_modify_attr?
      type == "~"
    end

    def is_modify_rule?
      !@diff[1].split(/[\[]/, 2)[1].nil?
    end

    def get_prev_instance
      prev_sg = self.clone
      prev_sg.add_security_rules(get_prev_rules)
      prev_sg
    end

    private

    def set_remote_security_group_id
      get_security_rules.each do |rule|
        unless rule['remote_group'].nil?
          remote_security_group = Kakine::Resource.security_group(@tenant_name, rule.delete("remote_group"))
          rule["remote_group_id"] = remote_security_group.id
        end
      end if has_rules?
    end

    def get_prev_rules
      registered_sg = Kakine::Resource.security_groups_hash(@tenant_name)
      if m = @diff[1].match(/^([\w-]+).([\w]+)\[(\d)\].([\w]+)$/)
        registered_sg[name]["rules"][m[3].to_i]
      end
    end
  end
end

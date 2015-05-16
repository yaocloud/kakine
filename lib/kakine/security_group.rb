require 'kakine/security_group/diff_parser'
module Kakine
  class SecurityGroup
    attr_reader :description, :tenant_name
    include DiffParser

    def initialize(tenant_name, diff)
      unset_security_rules
      @diff = diff
      @registered_sg = Kakine::Resource.security_groups_hash(tenant_name)

      init_parse_diff
      set_remote_security_group_id

      tenant_name  = tenant_name
    end

    def initialize_copy(obj)
      unset_security_rules
    end

    def transaction_type
      parse_transaction_type
    end

    def name
      parse_security_group_name
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
      end
    end

    def has_rules?
      @rules.detect {|v| !v.nil? && v.size > 0}
    end

    def is_add?
      transaction_type == "+"
    end

    def is_delete?
      transaction_type == "-"
    end

    def is_update_attr?
      transaction_type == "~"
    end

    def is_update_rule?
      !parse_target_object_name.split(/[\[]/, 2)[1].nil?
    end

    def get_prev_instance
      prev_sg = self.clone
      prev_sg.add_security_rules(parse_prev_rules)
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

    def unset_security_rules
      @rules = []
    end
  end
end

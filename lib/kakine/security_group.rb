require 'json'
module Kakine
  class SecurityGroup
    attr_reader :id, :name, :tenant_name, :description, :rules

    def initialize(tenant_name, params)
      @name        = params[0]
      @tenant_name = tenant_name
      @id          = params[1]["id"] || ""
      @description = params[1]["description"] || ""
      @rules       = get_rule_instances(params) || []
    end

    def tenant_id
      Yao.current_tenant_id
    end

    def ==(target_sg)
      same_group?(target_sg) && same_rule?(self, target_sg) && same_rule?(target_sg, self)
    end

    def !=(target_sg)
      !(self == target_sg)
    end

    def same_group?(target_sg)
      %i(@name @tenant_name @description).all? do |val|
        instance_variable_get(val) == target_sg.instance_variable_get(val)
      end
    end

    def same_rule?(a, b)
      a.rules.all? do |rule|
        b.find_by_rule(rule)
      end
    end

    def get_rule_instances(params)
      params[1]["rules"].map do |rule|
        SecurityRule.new(rule, @tenant_name, @name)
      end unless params[1]["rules"].nil?
    end

    def find_by_rule(target_rule)
      @rules.find { |rule| rule == target_rule }
    end

    def has_rules?
      @rules.detect {|v| !v.nil?}
    end
  end
end

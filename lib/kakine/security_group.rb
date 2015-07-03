require 'json'
module Kakine
  class SecurityGroup
    attr_reader :name, :tenant_id, :tenant_name, :description, :rules

    def initialize(tenant_name, parameter)
      @name = parameter[0]
      @tenant_name = tenant_name
      @tenant_id = Kakine::Resource.get(:openstack).tenant(tenant_name).id
      @description = parameter[1]["description"] || ""
      @rules = parameter[1]["rules"].map do |rule|
        SecurityRule.new(rule, @tenant_name, @name)
      end unless parameter[1]["rules"].nil?
      @rules ||= []
    end

    def ==(target_sg)
      same_group?(target_sg) && same_rule?(self, target_sg) && same_rule?(target_sg, self)
    end

    def same_group?(target_sg)
      instance_variables.reject{ |k| k == :@rules }.all? do |val|
        instance_variable_get(val) == target_sg.instance_variable_get(val)
      end
    end

    def same_rule?(a, b)
      a.rules.all? do |rule|
        b.find_by_rule(rule)
      end
    end

    def !=(target_sg)
      !(self == target_sg)
    end

    def find_by_rule(target_rule)
      @rules.find { |rule| rule == target_rule }
    end

    def has_rules?
      @rules.detect {|v| !v.nil?}
    end
  end
end

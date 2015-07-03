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

    def initialize_copy(obj)
      @rules = Marshal.load(Marshal.dump(obj.rules))
    end

    def ==(target_sg)
      instance_variables.reject{ |k| k == :@rules }.each do |val|
        return false unless self.instance_variable_get(val) == target_sg.instance_variable_get(val)
      end
      @rules.each do |rule|
        return false unless target_sg.find_by_rule(rule)
      end
      target_sg.rules.each do |rule|
        return false unless find_by_rule(rule)
      end
      true
    end

    def !=(target_sg)
      !(self == target_sg)
    end

    def find_by_rule(target_rule)
      @rules.find { |rule| rule == target_rule }
    end

    def unregister!
      Kakine::Builder.delete_security_group(self)
    end

    def convergence!(target_sg)
      if @description != target_sg.description
        target_sg.unregister!
        Kakine::Builder.create_security_group(self)
        @rules.each do |rule| 
          Kakine::Builder.create_security_rule(@tenant_name, @name, rule)
        end if has_rules?
      else
        target_sg.rules.each do |rule|
          rule.unregister! unless find_by_rule(rule)
        end
        @rules.each do |rule|
          unless target_sg.find_by_rule(rule)
            Kakine::Builder.create_security_rule(@tenant_name, @name, rule)
          end
        end
      end
    end

    def has_rules?
      @rules.detect {|v| !v.nil?}
    end

    def get_default_rule_instance
      default_sg = self.clone
      default_sg.set_default_rule
      default_sg
    end

    def set_default_rule
      @rules = %w(IPv4 IPv6).map { |v| {"direction"=>"egress", "protocol" => nil, "port"=>nil, "remote_ip"=>nil, "ethertype"=>v } }.
        map{ |rule| SecurityRule.new(rule, @tenant_name, @name) }
    end
  end
end

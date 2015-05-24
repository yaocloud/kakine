module Kakine
  class SecurityRule
    attr_reader :direction, :protocol, :port_range_max, :port_range_min, :remote_ip,
                :remote_group, :remote_group_id, :ethertype,:sg_name, :tenant_name

    def initialize(rule, tenant_name)
    def initialize(rule, sg_name, tenant_name)
      rule.each do|k,v|
        instance_variable_set(eval(":@#{k.to_s}"), v) unless k.include?("port")
      end
      @port_range_max, @port_range_min = *convert_port_format(rule)
      set_remote_security_group_id(tenant_name)!

      @sg_name = sg_name
      @tenant_name = tenant_name

      @operation = Kakine::Operation.new
    end

    def register!
      @operation.create_security_rule(self)
    end
    def convert_port_format(rule)
      case
      when rule.has_key?('port')
        [rule['port'] ,rule['port']]
      when rule.has_key?('type'), rule.has_key?('code')
        [rule['type'] ,rule['code']]
      when rule.has_key?('port_range_max'), rule.has_key?('port_range_min')
        [rule['port_range_max'] ,rule['port_range_min']]
      else
        raise "no match port format"
      end
    end

    def set_remote_security_group_id!(tenant_name)
      unless @remote_group.nil?
        remote_security_group = Kakine::Resource.security_group(tenant_name, @remote_group)
        @remote_group_id = remote_security_group.id
      end
    end
  end
end

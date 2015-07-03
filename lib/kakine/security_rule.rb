module Kakine
  class SecurityRule
    attr_reader :direction, :protocol, :port_range_max, :port_range_min, :remote_ip, :remote_group, :remote_group_id, :ethertype

    def initialize(rule, tenant_name, sg_name)
      @tenant_name = tenant_name
      @sg_name = sg_name

      rule.each do|k,v|
        instance_variable_set(eval(":@#{k.to_s}"), v) unless k.include?("port")
      end

      @port_range_min, @port_range_max = *convert_port_format(rule)
      set_remote_security_group_id

    end

    def unregister!
      Kakine::Builder.delete_security_rule(@tenant_name, @sg_name, self)
    end

    def ==(target_sg)
      instance_variables.each do |val|
        unless self.instance_variable_get(val) == target_sg.instance_variable_get(val)
          return false
        end
      end
      true
    end

    private

    def convert_port_format(rule)
      case
      when rule.has_key?('port')
        [rule['port'] ,rule['port']]
      when rule.has_key?('type'), rule.has_key?('code')
        [rule['type'] ,rule['code']]
      when rule.has_key?('port_range_max'), rule.has_key?('port_range_min')
        [rule['port_range_min'] ,rule['port_range_max']]
      else
        raise "no match port format"
      end
    end

    def set_remote_security_group_id
      unless @remote_group.nil?
        remote_security_group = Kakine::Resource.get(:openstack).security_group(@tenant_name, @remote_group)
        raise "not exists #{@remote_group}" unless remote_security_group
        @remote_group_id = remote_security_group.id
      end
    end
  end
end

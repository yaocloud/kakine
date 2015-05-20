module Kakine
  class SecurityRule
    attr_reader :direction, :protocol, :port_range_max, :port_range_min, :remote_ip, :remote_group, :remote_group_id, :ethertype

    def initialize(rule_hash, tenant_name)
      rule_hash.each do|k,v|
        instance_variable_set(eval(":@#{k.to_s}"), v) unless k.include?("port")
      end
      @port_range_max, @port_range_min = *convert_port_format(rule_hash)
    end

    def convert_port_format(rule_hash)
      case
      when rule_hash.has_key?('port')
        [rule_hash['port'] ,rule_hash['port']]
      when rule_hash.has_key?('type'), rule_hash.has_key?('code')
        [rule_hash['type'] ,rule_hash['code']]
      when rule_hash.has_key?('port_range_max'), rule_hash.has_key?('port_range_min')
        [rule_hash['port_range_max'] ,rule_hash['port_range_min']]
      else
        raise "no match port format"
      end
    end

    def set_remote_security_group_id(tenant_name)
      unless @remote_group.nil?
        remote_security_group = Kakine::Resource.security_group(tenant_name, @remote_group)
        @remote_group_id = remote_security_group.id
      end
    end
  end
end

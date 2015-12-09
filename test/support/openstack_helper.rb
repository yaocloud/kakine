module Kakine
  module OpenStack
    class Helper
      class << self
        def security_group
          sg_param = {
            "id" => "test_group_id_1",
            "name" => "test_group_name_1",
            "description"=>"test_description_1"
          }
          # ::Fog::Network::OpenStack::SecurityGroup.new(sg_param)
          ::Yao::SecurityGroup.new(sg_param)
        end

        def full_rule_port_remote_ip
          rule_param = {
            "id"                => "test_rule_id_1",
            "security_group_ip" => "test_group_id_1",
            "direction"         => "ingress",
            "protocol"          => "tcp",
            "ethertype"         => "IPv4",
            "port_range_max"    => "443",
            "port_range_min"    => "443",
            "remote_ip_prefix"  => "10.0.0.0/24",
            "remote_group_id"   => nil,
            "tenant_id"         => "test_tenant"
          }
          # ::Fog::Network::OpenStack::SecurityGroupRule.new(rule_param)
          ::Yao::SecurityGroupRule.new(rule_param)
        end

        def full_rule_range_remote_ip
          rule_param = {
            "id"                => "test_rule_id_1",
            "security_group_ip" => "test_group_id_1",
            "direction"         => "ingress",
            "protocol"          => "tcp",
            "ethertype"         => "IPv4",
            "port_range_max"    => "443",
            "port_range_min"    => "80",
            "remote_ip_prefix"  => "10.0.0.0/24",
            "remote_group_id"   => nil,
            "tenant_id"         => "test_tenant"
          }
          # ::Fog::Network::OpenStack::SecurityGroupRule.new(rule_param)
          ::Yao::SecurityGroupRule.new(rule_param)
        end

        def full_rule_icmp_remote_group
          rule_param = {
            "id"                => "test_rule_id_1",
            "security_group_ip" => "test_group_id_1",
            "direction"         => "ingress",
            "protocol"          => "icmp",
            "ethertype"         => "IPv4",
            "port_range_max"    => "8",
            "port_range_min"    => "10",
            "remote_ip_prefix"  => "10.0.0.0/24",
            "remote_group_id"   => nil,
            "tenant_id"         => "test_tenant"
          }
          # ::Fog::Network::OpenStack::SecurityGroupRule.new(rule_param)
          ::Yao::SecurityGroupRule.new(rule_param)
        end
      end
    end
  end
end

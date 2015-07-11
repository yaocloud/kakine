require 'minitest_helper'
require 'support/config_helper'

class TestKakineSecurityRule < Minitest::Test
  def test_accessor
    rule = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_port_remote_ip, "test_rule", "test_tenant") 
    assert_equal(rule.direction, "ingress") 
    assert_equal(rule.protocol, "tcp") 
    assert_equal(rule.port_range_max, "443") 
    assert_equal(rule.port_range_min, "443") 
    assert_equal(rule.remote_ip, "10.0.0.0/24") 
    assert_equal(rule.ethertype, "IPv4") 
    
    rule = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_icmp_remote_group, "test_rule", "test_tenant") 
    assert_equal(rule.port_range_max, "8") 
    assert_equal(rule.port_range_min, "10") 
    assert_equal(rule.remote_group, "test_group") 
  end
  
  def test_mathing_rule
    rule_a = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_port_remote_ip, "test_rule", "test_tenant") 
    rule_b = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_port_remote_ip, "test_rule", "test_tenant") 
    rule_c = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_icmp_remote_group, "test_rule", "test_tenant") 

    assert(rule_a == rule_b)
    refute(rule_a == rule_c)

  end
end

require 'minitest_helper'
require 'support/openstack_helper'
class TestKakineOpenStack < Minitest::Test
  def setup
    ::Fog::Network::OpenStack::SecurityGroup.any_instance.stubs(:security_group_rules).returns([Kakine::OpenStack::Helper.full_rule_port_remote_ip])
    Kakine::Resource.get(:openstack).stubs(:security_groups_on_tenant).returns([Kakine::OpenStack::Helper.security_group])
    Kakine::Option.stubs(:dryrun?).returns(true)
    Kakine::Option.stubs(:tenant_name).returns("test_tenant")
    Kakine::Resource.get(:openstack).stubs(:tenant).returns(Dummy.new)
  end

  def test_load_security_group
    sg = Kakine::Resource.get(:openstack).load_security_group.first
    rule = sg.rules[0]
    assert_equal(sg.name, "test_group_name_1") 
    assert_equal(sg.id, "test_group_id_1") 
    assert_equal(sg.tenant_name, "test_tenant") 
    assert_equal(sg.description, "test_description_1") 
    
    assert_equal(rule.id, "test_rule_id_1") 
    assert_equal(rule.direction, "ingress") 
    assert_equal(rule.protocol, "tcp") 
    assert_equal(rule.port_range_max, "443") 
    assert_equal(rule.port_range_min, "443") 
    assert_equal(rule.remote_ip, "10.0.0.0/24") 
    assert_equal(rule.ethertype, "IPv4") 
  end

  def test_port_hash
    assert_equal(Kakine::Resource.get(:openstack).port_hash(Kakine::OpenStack::Helper.full_rule_port_remote_ip),
                 { "port" =>"443" })
    assert_equal(Kakine::Resource.get(:openstack).port_hash(Kakine::OpenStack::Helper.full_rule_icmp_remote_group),
                 { "type" => "10", "code" => "8" })
    assert_equal(Kakine::Resource.get(:openstack).port_hash(Kakine::OpenStack::Helper.full_rule_range_remote_ip),
                 { "port_range_min" => "80", "port_range_max" => "443" })
  end
end

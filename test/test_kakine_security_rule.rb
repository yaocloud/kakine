require 'minitest_helper'
require 'support/test_helper'

class TestKakineSecurityRule < Minitest::Test
  def setup
    Kakine::Resource.get(:openstack).stubs(:security_groups_hash).returns(YAML.load_file('test/fixtures/cli/actual.yaml'))
    Kakine::Resource.get(:openstack).stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.get(:openstack).stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.get(:openstack).stubs(:security_group_rule).returns(Dummy.new)
    Kakine::SecurityGroup.stubs(:tenant_name).returns(Dummy.new)
  end
  def test_accessor
    rule = Kakine::SecurityRule.new(Kakine::TestHelper.full_rule_port_remote_ip, "test_rule", "test_tenant")
    assert_equal(rule.id, "test_id_1")
    assert_equal(rule.direction, "ingress")
    assert_equal(rule.protocol, "tcp")
    assert_equal(rule.port_range_max, "443")
    assert_equal(rule.port_range_min, "443")
    assert_equal(rule.remote_ip, "10.0.0.0/24")
    assert_equal(rule.ethertype, "IPv4")

    rule = Kakine::SecurityRule.new(Kakine::TestHelper.full_rule_icmp_remote_group, "test_rule", "test_tenant")
    assert_equal(rule.port_range_max, "8")
    assert_equal(rule.port_range_min, "10")
    assert_equal(rule.remote_group, "bob-b")
  end

  def test_mathing_rule
    change_id_rule = Kakine::TestHelper.full_rule_icmp_remote_group
    change_id_rule["id"] = "test_id_3"

    rule_a = Kakine::SecurityRule.new(Kakine::TestHelper.full_rule_port_remote_ip, "test_rule", "test_tenant")
    rule_b = Kakine::SecurityRule.new(Kakine::TestHelper.full_rule_port_remote_ip, "test_rule", "test_tenant")
    rule_c = Kakine::SecurityRule.new(Kakine::TestHelper.full_rule_icmp_remote_group, "test_rule", "test_tenant")
    rule_d    = Kakine::SecurityRule.new(change_id_rule, "test_rule", "test_tenant")

    assert(rule_a == rule_b)
    refute(rule_a == rule_c)

    # not use matching column by id
    assert(rule_c == rule_d)
  end

  def test_security_group_id
    rule = Kakine::SecurityRule.new(Kakine::TestHelper.full_rule_icmp_remote_group, "test_rule", "test_tenant")
    assert_equal(rule.remote_group_id, "awesome-id")
  end
end

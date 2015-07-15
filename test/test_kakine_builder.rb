require 'minitest_helper'
require 'support/config_helper'

class TestKakineBuilder < Minitest::Test
  def setup
    Kakine::Resource.get(:openstack).stubs(:security_groups_hash).returns([Kakine::Config::Helper.full_rule_security_group])
    Kakine::Options.stubs(:dryrun?).returns(true)
    Kakine::Options.stubs(:tenant_name).returns("test_tenant")
    Kakine::Resource.get(:openstack).stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.get(:openstack).stubs(:security_group).returns(nil)
  end

  def test_create_security_group
    full_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group) 
    assert_equal(Kakine::Builder.create_security_group(full_sg),"Create Security Group: test_full_group")
    
    short_rule_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.short_rule_security_group) 
    assert_equal(Kakine::Builder.create_security_group(short_rule_sg),"Create Security Group: test_short_group")
  end
  
  def test_delete_security_group
    sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group) 
    assert_equal(Kakine::Builder.delete_security_group(sg),"Delete Security Group: test_id_1")
  end

  def test_create_security_rule
    rule = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_port_remote_ip, "test_rule", "test_tenant") 
    assert_equal(Kakine::Builder.create_security_rule("test_tenant", "test_security_group", rule), "Create Rule: test_security_group")
  end

  def test_delete_security_rule
    rule = Kakine::SecurityRule.new(Kakine::Config::Helper.full_rule_port_remote_ip, "test_rule", "test_tenant") 
    assert_equal(Kakine::Builder.delete_security_rule("test_tenant", "test_security_group", rule), "Delete Rule: test_id_1")
  end

  def test_delete_default_security_rule
    assert_equal(Kakine::Builder.delete_default_security_rule("test_tenant", "test_full_group"), ["Delete Rule: test_id_1"])
  end

  def test_clean_up_security_group
    current_sgs = []
    new_sgs = []
    current_sgs << Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)
    current_sgs << Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.short_rule_security_group)
    new_sgs << Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)
    assert_equal(Kakine::Builder.clean_up_security_group(new_sgs, current_sgs), [nil, "Delete Security Group: test_id_2"]) 
  end
  
  def test_convergence_security_group
    current_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)
    lost_desc_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.lost_column("description"))
    assert_equal(Kakine::Builder.convergence_security_group(lost_desc_sg, current_sg), ["Create Rule: loss_description_group"] ) 
    
    icmp_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_security_group(Kakine::Config::Helper.full_rule_icmp_remote_group, "icmp_group"))
    assert_equal(Kakine::Builder.convergence_security_group(icmp_sg, current_sg), ["Create Rule: icmp_group"]) 
  end

  def test_already_setup_security_group
    current_sgs = []
    current_sgs << Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)
    current_sgs << Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.short_rule_security_group)
    new_sg =  Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)

    assert_equal(Kakine::Builder.already_setup_security_group(new_sg, current_sgs).name, "test_full_group")
  end

  def test_clean_up_security_rule
    current_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)
    new_sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.short_rule_security_group)
    assert_equal(Kakine::Builder.clean_up_security_rule(new_sg, current_sg), ["Delete Rule: test_id_1"]) 
  end

  def test_security_groups
    assert_equal(Kakine::Builder.security_groups, "---\n- - test_full_group\n  - rules:\n    - direction: ingress\n      protocol: tcp\n      ethertype: IPv4\n      port: '443'\n      remote_ip: 10.0.0.0/24\n    description: test_description\n")
  end
end

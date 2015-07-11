require 'minitest_helper'
require 'support/config_helper'

class TestKakineSecurityGroup < Minitest::Test
  
  def test_accessor
    sg = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group) 
    assert_equal(sg.name, "test_rule") 
    assert_equal(sg.id, "test_id") 
    assert_equal(sg.tenant_name, "test_tenant") 
    assert_equal(sg.description, "test_description") 
    assert(sg.rules[0].instance_of?(Kakine::SecurityRule)) 
  end

  def test_mathing_security_group
    sg_a = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group) 
    sg_b = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group)
    sg_c = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.lost_description)
    sg_d = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.lost_direction)
    
    assert(sg_a == sg_b)
    refute(sg_a != sg_b)

    refute(sg_a == sg_c)
    assert(sg_a != sg_c)
    
    refute(sg_a == sg_d)
    assert(sg_a != sg_d)
    
  end

  def test_has_rule?
    sg_a = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.full_rule_security_group) 
    sg_b = Kakine::SecurityGroup.new("test_tenant", Kakine::Config::Helper.short_rule_security_group) 

    assert(sg_a.has_rules?) 
    refute(sg_b.has_rules?) 
  end
end

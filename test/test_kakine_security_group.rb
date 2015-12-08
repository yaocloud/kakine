require 'minitest_helper'
require 'support/test_helper'

class TestKakineSecurityGroup < Minitest::Test

  def test_accessor
    sg = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.full_rule_security_group)
    assert_equal(sg.name, "test_full_group")
    assert_equal(sg.id, "test_id_1")
    assert_equal(sg.tenant_name, "test_tenant")
    assert_equal(sg.description, "test_description")
    assert(sg.rules[0].instance_of?(Kakine::SecurityRule))
  end

  def test_mathing_security_group
    sg_a = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.full_rule_security_group)
    sg_b = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.full_rule_security_group)
    sg_c = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.lost_column("description"))
    sg_d = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.lost_rule_column("direction"))

    assert(sg_a == sg_b)
    refute(sg_a != sg_b)

    refute(sg_a == sg_c)
    assert(sg_a != sg_c)

    refute(sg_a == sg_d)
    assert(sg_a != sg_d)

  end

  def test_has_rule?
    sg_a = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.full_rule_security_group)
    sg_b = Kakine::SecurityGroup.new("test_tenant", Kakine::TestHelper.short_rule_security_group)

    assert(sg_a.has_rules?)
    refute(sg_b.has_rules?)
  end
end

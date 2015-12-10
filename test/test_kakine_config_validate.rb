require 'minitest_helper'
require 'support/test_helper'

class TestKakineConfigValidate < Minitest::Test
  def test_validate_attributes
    # nothing raised
    Kakine::Resource.get(:yaml).validate_attributes(Kakine::TestHelper.full_rule_security_group)

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::TestHelper.lost_rules_with_description)
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::TestHelper.lost_column("rules"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::TestHelper.lost_column("description"))
    end
  end

  def test_validate_rules
    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("port"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("port_min"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("code"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("remote_ip"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("direction"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("protocol"))
    end

    assert_raises Kakine::ConfigureError do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::TestHelper.lost_rule_column("ethertype"))
    end
  end
end

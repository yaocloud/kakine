require 'minitest_helper'
require 'support/validate_helper'

class TestKakineConfigValidate < Minitest::Test
  def test_validate_attributes
    # nothing raised
    Kakine::Resource.get(:yaml).validate_attributes(Kakine::ValidateTest::Helper.full_rule_port_remote_ip)
    
    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::ValidateTest::Helper.lost_rules_with_description)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::ValidateTest::Helper.lost_rules)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::ValidateTest::Helper.lost_description)
    end
  end
end

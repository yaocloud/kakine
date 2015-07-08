require 'minitest_helper'
require 'support/config_helper'

class TestKakineConfigValidate < Minitest::Test
  def test_validate_attributes
    # nothing raised
    Kakine::Resource.get(:yaml).validate_attributes(Kakine::Config::Helper.full_rule_port_remote_ip)
    
    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::Config::Helper.lost_rules_with_description)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::Config::Helper.lost_rules)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_attributes(Kakine::Config::Helper.lost_description)
    end
  end
  
  def test_validate_rules
    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_port)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_port_min)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_port_code)
    end

    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_remote)
    end
    
    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_direction)
    end
    
    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_protocol)
    end
    
    assert_raises Kakine::Errors::Configure do
      Kakine::Resource.get(:yaml).validate_rules(Kakine::Config::Helper.lost_ethertype)
    end
  end
end

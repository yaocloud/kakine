require 'minitest_helper'

class TestKakineCLI < Minitest::Test
  def setup
    Kakine::Resource.stubs(:security_groups_hash).returns(YAML.load_file('test/fixtures/actual.yml'))
  end

  def test_create_security_group
  end

  def test_create_security_group_with_rule
  end

  def test_delete_security_group
  end

  def test_create_security_group_rule
  end

  def test_delete_security_group_rule
  end

  def test_update_security_group_rule
  end
end

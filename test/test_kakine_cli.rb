require 'minitest_helper'

class TestKakineCLI < Minitest::Test
  def setup
    Kakine::Resource.stubs(:security_groups_hash).returns(YAML.load_file('test/fixtures/actual.yaml'))
  end

  def test_create_security_group
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/expected001.yaml'))
    Kakine::Resource.stubs(:tenant).returns(DummyTenant.new)

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
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

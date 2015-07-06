require 'minitest_helper'

class TestKakineCLI < Minitest::Test
  def setup
    Kakine::Resource.get(:openstack).stubs(:security_groups_hash).returns(YAML.load_file('test/fixtures/cli/actual.yaml'))
    Kakine::Resource.get(:openstack).stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.get(:openstack).stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.get(:openstack).stubs(:security_group_rule).returns(Dummy.new)
    Kakine::SecurityGroup.stubs(:tenant_name).returns(Dummy.new)
  end

  def test_create_security_group
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected001.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_create_security_group_with_rule
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected002.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).twice
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).times(3)

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_delete_security_group
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected003.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_create_security_group_rule
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected004.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:create_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_delete_security_group_rule
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected005.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_update_security_group_rule
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected006.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:create_rule).twice
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_update_security_group_description
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected007.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).once
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_change_rule_position
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected008.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).never
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).never

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_no_rule_group
    Kakine::Resource.get(:yaml).stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected009.yaml'))

    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

end

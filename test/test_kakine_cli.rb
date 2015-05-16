require 'minitest_helper'

class TestKakineCLI < Minitest::Test
  def setup
    Kakine::Resource.stubs(:security_groups_hash).returns(YAML.load_file('test/fixtures/cli/actual.yaml'))
  end

  def test_create_security_group
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected001.yaml'))
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_create_security_group_with_rule
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected002.yaml'))
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).twice
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_delete_security_group
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected003.yaml'))
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_create_security_group_rule
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected004.yaml'))
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:create_rule).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_delete_security_group_rule
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected005.yaml'))
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_update_security_group_rule
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected006.yaml'))
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:create_rule).once
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end

  def test_update_security_group_description
    Kakine::Resource.stubs(:yaml).returns(YAML.load_file('test/fixtures/cli/expected007.yaml'))
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).once
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true})
  end
end

require 'minitest_helper'

class TestKakineCLI < Minitest::Test
  def setup
    Kakine::Resource.stubs(:security_groups_hash).returns(Hash[YAML.load_file('test/fixtures/cli/actual.yaml').to_hash.sort].sg_rules_sort)
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group).returns(Dummy.new)
    Kakine::Resource.stubs(:security_group_rule).returns(Dummy.new)
  end

  def test_create_security_group

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected001.yaml"})
  end

  def test_create_security_group_with_rule

    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).twice
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).times(3)

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected002.yaml"})
  end

  def test_delete_security_group

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected003.yaml"})
  end

  def test_create_security_group_rule

    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).times(2)
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).times(4)

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected004.yaml"})
  end

  def test_delete_security_group_rule

    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected005.yaml"})
  end

  def test_update_security_group_rule

    Kakine::Adapter::Mock.any_instance.expects(:create_rule).times(3)
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).times(3)

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected006.yaml"})
  end

  def test_update_security_group_description

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).once
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).once

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected007.yaml"})
  end

  def test_change_rule_position

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).never
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).never

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected008.yaml"})
  end

  def test_no_rule_group

    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).twice
    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).never

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected009.yaml"})
  end
  def test_validate_rules

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).never
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).never

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected010.yaml"})
  end
  def test_validate_description

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).never
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).never

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected011.yaml"})
  end
  def test_validate_attributes

    Kakine::Adapter::Mock.any_instance.expects(:delete_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_security_group).never
    Kakine::Adapter::Mock.any_instance.expects(:create_rule).never
    Kakine::Adapter::Mock.any_instance.expects(:delete_rule).never

    Kakine::CLI.new.invoke(:apply, [], {dryrun: true, filename: "test/fixtures/cli/expected012.yaml"})
  end
end

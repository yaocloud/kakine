require 'minitest_helper'

class TestKakineYaml < Minitest::Test
  def test_meta_section
    yaml = Kakine::Resource::Yaml.load_file('test/fixtures/yaml/meta_section.yaml')

    assert_equal 1, yaml.size
    assert_equal 2, yaml['web']['rules'].size
  end

  def test_rule_expansion
    yaml = Kakine::Resource::Yaml.load_file('test/fixtures/yaml/rule_expansion.yaml')

    assert_equal [], yaml['sg_nil']['rules']

    assert_equal 3, yaml['sg_port']['rules'].count

    assert_equal 2, yaml['sg_remote_ip']['rules'].count

    assert_equal 6, yaml['sg_port_remote_ip']['rules'].count

    assert_equal 4, yaml['sg_remote_ip_nested']['rules'].count

    assert_equal 2, yaml['sg_protocol']['rules'].count
  end

  def test_expand_rules
    # empty input
    assert_equal [], Kakine::Resource::Yaml.expand_rules([], 'key')

    # empty hash
    assert_equal [{}], Kakine::Resource::Yaml.expand_rules([{}], 'key')

    # unrelated keys
    assert_equal [{'other' => nil}], Kakine::Resource::Yaml.expand_rules([{'other' => nil}], 'key')
    assert_equal [{'other' => {}}], Kakine::Resource::Yaml.expand_rules([{'other' => {}}], 'key')
    assert_equal [{'other' => 0}], Kakine::Resource::Yaml.expand_rules([{'other' => 0}], 'key')
    assert_equal [{'other' => []}], Kakine::Resource::Yaml.expand_rules([{'other' => []}], 'key')
    assert_equal [{'other' => [0, 1]}], Kakine::Resource::Yaml.expand_rules([{'other' => [0, 1]}], 'key')

    # scalar values
    assert_equal [{'key' => 10}], Kakine::Resource::Yaml.expand_rules([{'key' => 10}], 'key')
    assert_equal [{'key' => 10, 'other' => 0}], Kakine::Resource::Yaml.expand_rules([{'key' => 10, 'other' => 0}], 'key')

    # empty arrays
    assert_equal [], Kakine::Resource::Yaml.expand_rules([{'key' => []}], 'key')
    assert_equal [], Kakine::Resource::Yaml.expand_rules([{'key' => [], 'other' => 0}], 'key')

    # singleton arrays
    assert_equal [{'key' => 10}], Kakine::Resource::Yaml.expand_rules([{'key' => [10]}], 'key')
    assert_equal [{'key' => 10, 'other' => 0}], Kakine::Resource::Yaml.expand_rules([{'key' => [10], 'other' => 0}], 'key')

    # arrays
    assert_equal [{'key' => 10}, {'key' => 20}], Kakine::Resource::Yaml.expand_rules([{'key' => [10, 20]}], 'key')
    assert_equal [{'key' => 10, 'other' => 0}, {'key' => 20, 'other' => 0}], Kakine::Resource::Yaml.expand_rules([{'key' => [10, 20], 'other' => 0}], 'key')

    # nil is scalar
    assert_equal [{'key' => nil}], Kakine::Resource::Yaml.expand_rules([{'key' => nil}], 'key')
    assert_equal [{'key' => nil, 'other' => 0}], Kakine::Resource::Yaml.expand_rules([{'key' => nil, 'other' => 0}], 'key')

    # singleton array of nil
    assert_equal [{'key' => nil}], Kakine::Resource::Yaml.expand_rules([{'key' => [nil]}], 'key')
    assert_equal [{'key' => nil, 'other' => 0}], Kakine::Resource::Yaml.expand_rules([{'key' => [nil], 'other' => 0}], 'key')

    # nested arrays
    assert_equal [], Kakine::Resource::Yaml.expand_rules([{'key' => [[]]}], 'key')
    assert_equal [], Kakine::Resource::Yaml.expand_rules([{'key' => [[], []]}], 'key')
    assert_equal [{'key' => nil}], Kakine::Resource::Yaml.expand_rules([{'key' => [[nil]]}], 'key')
    assert_equal [{'key' => 10}, {'key' => 20}, {'key' => 30}], Kakine::Resource::Yaml.expand_rules([{'key' => [10, [20, 30]]}], 'key')

    # multiple inputs
    assert_equal [{}, {}], Kakine::Resource::Yaml.expand_rules([{}, {}], 'key')
    assert_equal [{'other' => 0}, {'other' => 1}], Kakine::Resource::Yaml.expand_rules([{'other' => 0}, {'other' => 1}], 'key')
    assert_equal [{'key' => 10}, {'key' => 20}], Kakine::Resource::Yaml.expand_rules([{'key' => 10}, {'key' => 20}], 'key')
    assert_equal [{'key' => 10, 'other' => 0}, {'key' => 20}], Kakine::Resource::Yaml.expand_rules([{'key' => 10, 'other' => 0}, {'key' => 20}], 'key')
    assert_equal [{'key' => 10}, {'key' => 20}, {'key' => 30}], Kakine::Resource::Yaml.expand_rules([{'key' => 10}, {'key' => [20, 30]}], 'key')

    # matrix expansion
    assert_equal [{'key0' => 10, 'key1' => 50}, {'key0' => 10, 'key1' => 60}, {'key0' => 20, 'key1' => 50}, {'key0' => 20, 'key1' => 60}],
                 Kakine::Resource::Yaml.expand_rules(Kakine::Resource::Yaml.expand_rules([{'key0' => [10, 20], 'key1' => [50, 60]}], 'key0'), 'key1')
  end
end

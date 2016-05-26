require 'minitest_helper'

class TestKakineYaml < Minitest::Test
  def test_meta_section
    yaml = Kakine::Resource::Yaml.yaml('test/fixtures/yaml/meta_section.yaml')

    assert_equal 1, yaml.size
    assert_equal 2, yaml['web']['rules'].size
  end
end

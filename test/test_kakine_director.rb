require 'minitest_helper'

class TestKakineDirector < Minitest::Test
  def test_convert_terraform
    Kakine::Option.set_options(filename: 'test/fixtures/simple.yaml')

    out = String.new
    $stdout = StringIO.new(out)
    begin
      Kakine::Director.convert('terraform', nil)
      json = JSON.parse(out)
      assert_kind_of Hash, json['resource']['openstack_networking_secgroup_v2']
      assert_equal 1, json['resource']['openstack_networking_secgroup_v2'].size
      assert_kind_of Hash, json['resource']['openstack_networking_secgroup_rule_v2']
      assert_equal 2, json['resource']['openstack_networking_secgroup_rule_v2'].size
      assert_kind_of Hash, json['output']['security_groups']
      assert_equal 1, json['output']['security_groups'].size
      assert_kind_of Array, json['output']['security_groups']['value']
      assert_equal 1, json['output']['security_groups']['value'].size
    ensure
      $stdout = STDOUT
    end
  end

  def test_convert_terraform_file
    Kakine::Option.set_options(filename: 'test/fixtures/simple.yaml')

    out = Tempfile.new('')
    begin
      Kakine::Director.convert('terraform', out)
      out.rewind
      json = JSON.parse(out.read)
      assert_kind_of Hash, json['resource']['openstack_networking_secgroup_v2']
      assert_equal 1, json['resource']['openstack_networking_secgroup_v2'].size
      assert_kind_of Hash, json['resource']['openstack_networking_secgroup_rule_v2']
      assert_equal 2, json['resource']['openstack_networking_secgroup_rule_v2'].size
      assert_kind_of Hash, json['output']['security_groups']
      assert_equal 1, json['output']['security_groups'].size
      assert_kind_of Array, json['output']['security_groups']['value']
      assert_equal 1, json['output']['security_groups']['value'].size
    ensure
      out.close!
    end
  end
end

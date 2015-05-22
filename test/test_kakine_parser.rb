require 'minitest_helper'

class TestKakineDiffParser < Minitest::Test
  def setup
    Kakine::Resource.stubs(:security_groups_hash).returns(YAML.load_file('test/fixtures/parser/actual.yaml'))
    Kakine::Resource.stubs(:tenant).returns(Dummy.new)
  end

  def test_create_security_group_with_rule
    sg = Kakine::SecurityGroup.new(Dummy.new.id, YAML.load_file('test/fixtures/parser/expected001.yaml'))
    assert_equal(sg.name, "bob-a")
    assert_equal(sg.transaction_type, "+")
    assert_equal(sg.tenant_id, Dummy.new.id)
    assert_equal(sg.tenant_name, Dummy.new.id)
    assert_equal(sg.description, "snmp")
    assert_equal(sg.rules, [{"direction"=>"ingress", "protocol"=>"udp", "port"=>162, "remote_ip"=>"172.17.4.0/24", "ethertype"=>"IPv4"}])
  end

  def test_delete_security_group
    sg = Kakine::SecurityGroup.new(Dummy.new.id, YAML.load_file('test/fixtures/parser/expected002.yaml'))
    assert_equal(sg.name, "bob-a")
    assert_equal(sg.transaction_type, "-")
    assert_equal(sg.tenant_id, Dummy.new.id)
    assert_equal(sg.tenant_name, Dummy.new.id)
    assert_equal(sg.description, "snmp")
    assert_equal(sg.rules, [{"direction"=>"ingress", "protocol"=>"udp", "port"=>162, "remote_ip"=>"172.17.4.0/24", "ethertype"=>"IPv4"}])
  end

  def test_create_security_group_rule
    sg = Kakine::SecurityGroup.new(Dummy.new.id, YAML.load_file('test/fixtures/parser/expected003.yaml'))
    assert_equal(sg.name, "bob-b")
    assert_equal(sg.transaction_type, "+")
    assert_equal(sg.tenant_id, Dummy.new.id)
    assert_equal(sg.tenant_name, Dummy.new.id)
    assert_equal(sg.description, "bob-b")
    assert_equal(sg.rules, [{"direction"=>"ingress", "protocol"=>"udp", "port"=>162, "remote_ip"=>"172.17.4.0/24", "ethertype"=>"IPv4"}])
  end

  def test_delete_security_group_rule
    sg = Kakine::SecurityGroup.new(Dummy.new.id, YAML.load_file('test/fixtures/parser/expected004.yaml'))
    assert_equal(sg.name, "bob-b")
    assert_equal(sg.transaction_type, "-")
    assert_equal(sg.tenant_id, Dummy.new.id)
    assert_equal(sg.tenant_name, Dummy.new.id)
    assert_equal(sg.description, "bob-b")
    assert_equal(sg.rules, [{"direction"=>"ingress", "protocol"=>"udp", "port"=>162, "remote_ip"=>"172.17.4.0/24", "ethertype"=>"IPv4"}])

  end

  def test_update_security_group_description
    sg = Kakine::SecurityGroup.new(Dummy.new.id, YAML.load_file('test/fixtures/parser/expected005.yaml'))
    assert_equal(sg.name, "bob-b")
    assert_equal(sg.transaction_type, "~")
    assert_equal(sg.tenant_id, Dummy.new.id)
    assert_equal(sg.tenant_name, Dummy.new.id)
    assert_equal(sg.description, "change_description")
    assert_equal(sg.rules, [{"direction"=>"ingress", "protocol"=>"tcp", "port"=>443, "remote_ip"=>"0.0.0.0/0", "ethertype"=>"IPv4"},
    {"direction"=>"ingress", "protocol"=>"tcp", "port"=>80, "remote_ip"=>"0.0.0.0/0", "ethertype"=>"IPv4"}])
  end

  def test_update_security_group_attributes
    sg = Kakine::SecurityGroup.new(Dummy.new.id, YAML.load_file('test/fixtures/parser/expected006.yaml'))
    assert_equal(sg.name, "bob-b")
    assert_equal(sg.transaction_type, "~")
    assert_equal(sg.tenant_id, Dummy.new.id)
    assert_equal(sg.tenant_name, Dummy.new.id)
    assert_equal(sg.description, "bob-b")
    assert_equal(sg.rules, [{"direction"=>"ingress", "protocol"=>"tcp", "port"=>1000, "remote_ip"=>"0.0.0.0/0", "ethertype"=>"IPv4"}])
  end
end

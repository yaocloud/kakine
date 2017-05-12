require 'minitest_helper'
require 'support/test_helper'

class TestKakineExporterTerraform < Minitest::Test
  def setup
    tenant = 'my-tenant'
    @sgs = [
      Kakine::SecurityGroup.new(
        tenant,
        [
          'default',
          'description' => 'Allow internal communication',
          'rules' => [
            {
              'direction' => 'ingress',
              'ethertype' => 'IPv4',
              'port_range_max' => nil,
              'port_range_min' => nil,
              'protocol' => nil,
              'remote_group' => 'default',
            },
          ],
        ],
      ),
      Kakine::SecurityGroup.new(
        tenant,
        [
          'www',
          'description' => 'Allow HTTP/HTTPS',
          'rules' => [
            {
              'direction' => 'ingress',
              'ethertype' => 'IPv4',
              'port_range_max' => 80,
              'port_range_min' => 80,
              'protocol' => 'tcp',
              'remote_ip_prefix' => '192.0.2.0/24',
            },
            {
              'direction' => 'ingress',
              'ethertype' => 'IPv4',
              'port_range_max' => 443,
              'port_range_min' => 443,
              'protocol' => 'tcp',
              'remote_ip_prefix' => '192.0.2.0/24',
            },
          ],
        ],
      ),
    ]
  end

  def test_export
    out = String.new
    exporter = Kakine::Exporter::Terraform.new(StringIO.new(out, 'w'))
    exporter.export(@sgs)

    expected = {
      'resource' => {
        'openstack_networking_secgroup_v2' => {
          'default' => {
            'name' => 'default',
            'description' => 'Allow internal communication'
          },
          'www' => {
            'name' => 'www',
            'description' => 'Allow HTTP/HTTPS'
          }
        },
        'openstack_networking_secgroup_rule_v2' => {
          'default-ingress_IPv4_default' => {
            'direction' => 'ingress',
            'ethertype' => 'IPv4',
            'remote_group_id' => '${openstack_networking_secgroup_v2.default.id}',
            'security_group_id' => '${openstack_networking_secgroup_v2.default.id}'
          },
          'www-ingress_IPv4_tcp_80_80' => {
            'direction' => 'ingress',
            'ethertype' => 'IPv4',
            'protocol' => 'tcp',
            'port_range_min' => 80,
            'port_range_max' => 80,
            'security_group_id' => '${openstack_networking_secgroup_v2.www.id}'
          },
          'www-ingress_IPv4_tcp_443_443' => {
            'direction' => 'ingress',
            'ethertype' => 'IPv4',
            'protocol' => 'tcp',
            'port_range_min' => 443,
            'port_range_max' => 443,
            'security_group_id' => '${openstack_networking_secgroup_v2.www.id}'
          }
        }
      },
      'output' => {
        'security_groups' => {
          'value' => [
            {
              'default' => '${openstack_networking_secgroup_v2.default.id}',
              'www' => '${openstack_networking_secgroup_v2.www.id}'
            }
          ]
        }
      }
    }

    assert_equal expected, JSON.parse(out)
  end
end

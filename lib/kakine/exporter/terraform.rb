module Kakine
  module Exporter
    class Terraform
      def initialize(output, pretty: true)
        @output = output
        @pretty = pretty
      end

      def export(security_groups)
        write(generate(security_groups))
      end

      private

      def write(tf)
        @output.write(@pretty ? JSON.pretty_generate(tf) : JSON.generate(tf))
      end

      def generate(security_groups)
        {
          resource: {
            'openstack_networking_secgroup_v2' => generate_security_groups(security_groups),
            'openstack_networking_secgroup_rule_v2' => generate_security_group_rules(security_groups),
          },
        }
      end

      def generate_security_groups(security_groups)
        security_groups.each.with_object({}) do |security_group, resources|
          resources[sanitize(security_group.name)] = {
            name: security_group.name,
            description: security_group.description,
          }
        end
      end

      def generate_security_group_rules(security_groups)
        security_groups.each.with_object({}) do |security_group, resources|
          security_group.rules.each do |rule|
            name = [sanitize(security_group.name), sanitize(identify(rule))].join('-')
            resources[name] =  compact_hash(
              direction: rule.direction,
              ethertype: rule.ethertype,
              protocol: rule.protocol,
              port_range_min: rule.port_range_min,
              port_range_max: rule.port_range_max,
              remote_ip_prefix: rule.remote_ip,
              remote_group_id: ("${openstack_networking_secgroup_v2.#{sanitize(rule.remote_group)}.id}" if rule.remote_group),
              security_group_id: "${openstack_networking_secgroup_v2.#{sanitize(security_group.name)}.id}",
            )
          end
        end
      end

      # Generates a unique name for a SG rule.
      def identify(rule)
        [
          rule.direction,
          rule.ethertype,
          rule.protocol,
          rule.port_range_min,
          rule.port_range_max,
          rule.remote_ip,
          rule.remote_group,
        ].compact.map(&method(:sanitize)).join('-')
      end

      # Returns a string that can be used as a Terraform resource name.
      def sanitize(name)
        name.to_s.gsub(/\W/, '_')
      end

      def compact_hash(hash)
        return hash.compact if hash.respond_to?(:compact)
        hash.each.with_object({}) {|(k, v), hash| hash[k] = v unless v.nil? }
      end
    end
  end
end


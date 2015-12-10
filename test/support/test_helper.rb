module Kakine
  module TestHelper
    class << self

      def full_rule_security_group
        full_security_group(full_rule_port_remote_ip, "test_full_group")
      end

      def full_security_group(rule, name)
        [
          name,
          {
            "rules" => [
              rule
            ],
            "description" => "test_description",
            "id"          => "test_id_1"
          }
        ]
      end

      def short_rule_security_group
        [
          "test_short_group",
          {
            "rules" => [
            ],
            "description" => "test_description",
            "id"          => "test_id_2"
          }
        ]
      end

      def full_rule_port_remote_ip
        {
          "id"        => "test_id_1",
          "direction" => "ingress",
          "protocol"  => "tcp",
          "ethertype" => "IPv4",
          "port"      =>  "443",
          "remote_ip" => "10.0.0.0/24"
        }
      end

      def full_rule_icmp_remote_group
        {
          "id"            => "test_id_2",
          "direction"     => "ingress",
          "protocol"      => "tcp",
          "ethertype"     => "IPv4",
          "type"          =>  "10",
          "code"          =>  "8",
          "remote_group"  => "bob-b"
        }
      end

      def lost_rules_with_description
        conf = full_rule_security_group
        conf[1].delete("rules")
        conf[1].delete("description")
        conf[0] = "loss_rules_with_descripion_group"
        conf
      end

      def lost_column(col)
        conf = full_rule_security_group
        conf[1].delete(col)
        conf[0] = "loss_#{col}_group"
        conf
      end

      def lost_rule_column(col)
        conf = full_rule_security_group
        conf[1]["rules"][0].delete(col)
        conf[0] = "loss_#{col}_group"
        case col
        when "port_min"
          conf[1]["rules"][0].delete("port")
          conf[1]["rules"][0]["port_max"] = 80;
        when "code"
          conf[1]["rules"][0].delete("port")
          conf[1]["rules"][0]["type"] = 80;
        end
        conf
      end
    end
  end
end

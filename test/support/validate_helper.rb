module Kakine
  module ValidateTest
    class Helper
      class << self
        def full_rule_port_remote_ip
          [
            "test_rule",
            {
              "rules" => [
                {
                  "direction" => "ingress",
                  "protocol"  => "tcp",
                  "ethertype" => "IPv4",
                  "port"      =>  "443",
                  "remote_ip" => "10.0.0.0/24"
                }
              ],
              "description" => "test_description"
            }
          ]
        end

        def lost_rules_with_description
          conf = full_rule_port_remote_ip
          conf[1].delete("rules")
          conf[1].delete("description")
          conf
        end

        def lost_rules
          conf = full_rule_port_remote_ip
          conf[1].delete("rules")
          conf
        end

        def lost_description
          conf = full_rule_port_remote_ip
          conf[1].delete("description")
          conf
        end
      end
    end
  end
end

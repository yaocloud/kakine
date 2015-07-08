module Kakine
  module Config
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

        def lost_port
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("port")
          conf
        end
        
        def lost_port_min
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("port")
          conf[1]["rules"][0]["port_max"] = 80;
          conf
        end

        def lost_port_code
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("port")
          conf[1]["rules"][0]["type"] = 80;
          conf
        end
        
        def lost_remote
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("remote_ip")
          conf
        end
        
        def lost_direction
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("direction")
          conf
        end
        
        def lost_protocol
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("protocol")
          conf
        end
        
        def lost_ethertype
          conf = full_rule_port_remote_ip
          conf[1]["rules"][0].delete("ethertype")
          conf
        end
      end
    end
  end
end

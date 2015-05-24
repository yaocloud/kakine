module Kakine
  class Validate
    class << self
      def validate_file_input(load_sg)
        err = []
        load_sg.each do |sg|
          err << validate_attributes(sg)
          err << validate_rules(sg)
        end
        if err.detect {|e| !e.nil? }
          err.map { |m| puts m unless m.nil? }
          false
        else
          true
        end
      end

      def validate_attributes(sg)
        case
        when sg[1].nil?
          "[error] #{sg[0]}:rules and description is required"
        when !sg[1].key?("rules")
          "[error] #{sg[0]}:rules is required"
        when !sg[1].key?("description")
          "[error] #{sg[0]}:description is required"
        end
      end

      def validate_rules(sg)
        sg[1]["rules"].each do |rule|
          case
          when !rule.key?("port") &&
          (!rule.key?("port_range_max") || !rule.key?("port_range_min")) &&
          ((!rule.key?("type") || !rule.key?("code")))
            return "[error] #{sg[0]}:rules port(icmp code) is required"
          when !rule.key?("remote_ip") && !rule.key?("remote_group")
            return "[error] #{sg[0]}:rules remote_ip or remote_group required"
          else
            %w(direction protocol ethertype).each do |k|
              if !rule.key?(k)
                return "[error] #{sg[0]}:rules #{k} is required"
              end
            end
          end
        end unless sg[1]["rules"].nil?
        nil
      end
    end
  end
end

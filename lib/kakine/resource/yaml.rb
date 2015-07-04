module Kakine
  class Resource
    class Yaml
      class << self
        def load_security_group
          load_yaml = yaml(Kakine::Options.yaml_name)
          validate_file_input(load_yaml)
          load_yaml.map { |sg| Kakine::SecurityGroup.new(Kakine::Options.tenant_name, sg) }
        end

        def yaml(filename)
          YAML.load_file(filename).to_hash
        end

        def validate_file_input(load_sg)
          load_sg.each do |sg|
            validate_attributes(sg)
            validate_rules(sg)
          end
          true
        end

        def validate_attributes(sg)
          sg_name = sg[0]
          case
          when sg[1].nil?
            raise(Kakine::Errors::Configure, "#{sg_name}:rules and description is required")
          when !sg[1].key?("rules")
            raise(Kakine::Errors::Configure, "#{sg_name}:rules is required")
          when !sg[1].key?("description")
            raise(Kakine::Errors::Configure, "#{sg_name}:description is required")
          end
        end

        def validate_rules(sg)
          sg_name = sg[0]
          sg[1]["rules"].each do |rule|
            case
            when !has_port?(rule)
              raise(Kakine::Errors::Configure,  "#{sg_name}:rules port(icmp code) is required")
            when !has_remote?(rule)
              raise(Kakine::Errors::Configure, "#{sg_name}:rules remote_ip or remote_group required")
            when !has_direction?(rule)
              raise(Kakine::Errors::Configure, "#{sg_name}:rules direction is required")
            when !has_protocol?(rule)
              raise(Kakine::Errors::Configure, "#{sg_name}:rules protocol is required")
            when !has_ethertype?(rule)
              raise(Kakine::Errors::Configure, "#{sg_name}:rules ethertype is required")
            end
          end unless sg[1]["rules"].nil?
        end

        def has_port?(rule)
          rule.key?("port") ||
          ( rule.key?("port_range_max") && rule.key?("port_range_min") ) ||
          ( rule.key?("type") && rule.key?("code") )
        end

        def has_remote?(rule)
          rule.key?("remote_ip") || rule.key?("remote_group")
        end

        def has_direction?(rule)
          rule.key?("direction")
        end

        def has_protocol?(rule)
          rule.key?("protocol")
        end

        def has_ethertype?(rule)
          rule.key?("ethertype")
        end
      end
    end
  end
end

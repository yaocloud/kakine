module Kakine
  class SecurityGroup
    module DiffParser
      private
      def init_parse_diff
        if ["+", "-"].include?(parse_transaction_type)
          if unit_is_security_group?
            add_security_rules(parse_security_group["rules"])
            @description = parse_security_group["description"]
          elsif unit_is_security_rule?
            add_security_rules(parse_security_group_rule)
            @description = @registered_sg[parse_security_group_name]["description"]
          end
        else
          regex_update_description = /^[\w-]+\.[\w]+$/
          regex_update_attr        = /^[\w-]+.[\w]+\[(\d)\].([\w]+)$/

          if parse_target_object_name.match(regex_update_description)
            add_security_rules(@registered_sg[parse_security_group_name]["rules"])
            @description = parse_after_description
          elsif m = parse_target_object_name.match(regex_update_attr)
            rules = @registered_sg[parse_security_group_name]["rules"][m[1].to_i]
            rules[m[2]] = parse_after_attr
            add_security_rules(rules)
            @description = @registered_sg[parse_security_group_name]["description"]
          end
        end
      end

      def parse_security_group_name
        parse_target_object_name.split(/[\.\[]/, 2)[0]
      end

      def parse_prev_rules
        if m = parse_target_object_name.match(/^[\w-]+.[\w]+\[(\d)\].[\w]+$/)
          @registered_sg[parse_security_group_name]["rules"][m[1].to_i]
        end
      end

      def parse_transaction_type
        @diff[0]
      end

      def parse_target_object_name
        @diff[1]
      end

      def parse_security_group
        @diff[2]
      end
      alias :parse_security_group_rule :parse_security_group

      def parse_after_attr
        @diff[3]
      end
      alias :parse_after_description :parse_after_attr

      def unit_is_security_group?
        parse_security_group && parse_security_group["rules"]
      end

      def unit_is_security_rule?
        !parse_security_group_rule.nil?
      end
    end
  end
end

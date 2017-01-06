module Kakine
  module Adapter
    class Real
      include Kakine::Adapter::Base
      def create_rule(security_group_id, direction, security_rule)
        begin
          security_rule = symbolized_rule(security_rule)
          Yao::SecurityGroupRule.create(security_rule.merge({'security_group_id' => security_group_id, 'direction' => direction}))
        rescue Yao::Conflict, Yao::BadRequest => e
          error_message(e.message)
        rescue Kakine::SecurityRuleError => e
          puts e
        end
      end

      def delete_rule(security_group_rule_id)
        Yao::SecurityGroupRule.destroy(security_group_rule_id)
      end

      def create_security_group(attributes)
        begin
          security_group = Yao::SecurityGroup.create(symbolized_group(attributes))
          {"id" => security_group.id}
        rescue Yao::Conflict, Yao::BadRequest => e
          error_message(e.message)
        end
      end

      def delete_security_group(security_group_id)
        begin
          Yao::SecurityGroup.destroy(security_group_id)
        rescue Yao::Conflict, Yao::BadRequest => e
          error_message(e.message)
        end
      end

      private

      def error_message(errors)
        if errors.kind_of?(JSON)
          JSON.parse(errors.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
        else
          puts errors
        end
      end

      def symbolized_group(attributes)
        attributes.inject({}){|data,(k,v)|data[k.to_sym] = v; data }
      end

      def symbolized_rule(security_rule)
        attributes = {}
        %w(protocol port_range_max port_range_min ethertype).each do |k|
          attributes[k.to_sym] = security_rule.send(k)
        end

        if security_rule.remote_group
          attributes[:remote_group_id] = security_rule.remote_group_id
        elsif security_rule.remote_ip
          attributes[:remote_ip_prefix] = security_rule.remote_ip
        end

        attributes
      end
    end
  end
end

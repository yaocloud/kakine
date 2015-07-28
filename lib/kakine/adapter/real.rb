module Kakine
  class Adapter
    class Real
      include Kakine::Adapter::Base
      def create_rule(security_group_id, direction, security_rule)
        begin
          Fog::Network[:openstack].create_security_group_rule(security_group_id, direction, symbolized_rule(security_rule))
        rescue Excon::Errors::Conflict, Excon::Errors::BadRequest => e
          error_message(e.response[:body])
        rescue Kakine::SecurityRuleError => e
          puts e
        end
      end

      def delete_rule(security_group_rule_id)
        Fog::Network[:openstack].delete_security_group_rule(security_group_rule_id)
      end

      def create_security_group(attributes)
        begin
          response = Fog::Network[:openstack].create_security_group(symbolized_group(attributes))
          response.data[:body]["security_group"]["id"]
        rescue Excon::Errors::Conflict, Excon::Errors::BadRequest => e
          error_message(e.response[:body])
        end
      end

      def delete_security_group(security_group_id)
        begin
          Fog::Network[:openstack].delete_security_group(security_group_id)
        rescue Excon::Errors::Conflict, Excon::Errors::BadRequest => e
          error_message(e.response[:body])
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
        %w(protocol port_range_max port_range_min remote_ip ethertype).each do |k|
          attributes[k.to_sym] = security_rule.send(k)
        end

        if security_rule.has_security_group?
          attributes[:remote_group_id] = security_rule.remote_group_id
        else  
          attributes[:remote_ip_prefix] = attributes.delete(:remote_ip) if attributes[:remote_ip]
        end
        attributes
      end
    end
  end
end

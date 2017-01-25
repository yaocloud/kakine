module Kakine
  module Exporter
    def self.get(type)
      case type.to_sym
      when :terraform
        Kakine::Exporter::Terraform
      else
        fail "Unknown exporter: #{type}"
      end
    end
  end
end

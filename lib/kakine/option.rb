require 'singleton'
module Kakine
  class Option
    include Singleton
    class << self
      def set_options(options)
        @@options = options
      end

      def yaml_name
        @@options[:filename] ? @@options[:filename] : "#{@@options[:tenant]}.yaml"
      end

      def tenant_name
        @@options["tenant"]
      end

      def dryrun?
        @@options["dryrun"]
      end
    end
  end
end

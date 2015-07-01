require 'singleton'
module Kakine
  class Adapter
    include Singleton
    class << self
      def set_option(dryrun)
        @@dryrun = dryrun
      end

      def instance
        @@adapter ||= if @@dryrun
          Kakine::Adapter::Mock.new
        else
          Kakine::Adapter::Real.new
        end
      end
    end
  end
end

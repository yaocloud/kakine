require 'singleton'
module Kakine
  class Adapter
    @@adapter = nil
    include Singleton
    class << self
      def instance
        @@adapter ||= if Kakine::Option.dryrun?
          Kakine::Adapter::Mock.new
        else
          Kakine::Adapter::Real.new
        end
      end
    end
  end
end

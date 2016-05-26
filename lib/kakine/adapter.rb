module Kakine
  module Adapter
    class << self
      def instance
        @@adapter ||=
          if Kakine::Option.dryrun?
            Kakine::Adapter::Mock.new
          else
            Kakine::Adapter::Real.new
          end
      end
    end
  end
end

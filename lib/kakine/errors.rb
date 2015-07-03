module Kakine
  module Errors
    class Error < StandardError; end
    class Configure < Error; end
    class SecurityRule < Error; end
  end
end

require 'kakine/adapter/real'
require 'kakine/adapter/mock'

module Kakine
  class Adapter
    def self.set_option(dryrun)
      @@dryrun = dryrun
    end

    def self.get_instance
      @@adapter ||= if @@dryrun
        Kakine::Adapter::Mock.new
      else
        Kakine::Adapter::Real.new
      end
    end

    private
    def initialize
    end
  end
end

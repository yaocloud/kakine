module Kakine
  class Resource
    class << self
      def get(type)
        case
        when type == :yaml
          Kakine::Resource::Yaml
        when type == :openstack
          Kakine::Resource::OpenStack
        end
      end
    end
  end
end

module Kakine
  class Resource
    class Yaml
      class << self
        def load_security_group(filename, tenant_name)
          load_yaml = yaml(filename)
          Kakine::Validate.validate_file_input(load_yaml)

          load_yaml.map { |sg| Kakine::SecurityGroup.new(tenant_name, sg) }

          raise(Kakine::Errors::Configure, "can't load config by yaml") unless load_yaml
          load_yaml
        end

        def yaml(filename)
          YAML.load_file(filename).to_hash
        end
      end
    end
  end
end

require 'thor'
require 'fog'
require 'yaml'
require 'hashdiff'

module Kakine
  class CLI < Thor

    option :tenant, type: :string, aliases: '-t'
    desc 'show', 'show Security Groups specified tenant'
    def show
      puts Kakine::Resource.security_groups_hash(options[:tenant]).to_yaml
    end

    option :tenant, type: :string, aliases: "-t"
    option :dryrun, type: :boolean, aliases: "-d"
    option :filename, type: :string, aliases: "-f"
    desc 'apply', "apply local configuration into OpenStack"
    def apply
      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"
      operation = Kakine::CLI::Operation.new

      adapter = if options[:dryrun]
        Kakine::Adapter::Mock.new
      else
        Kakine::Adapter::Real.new
      end

      operation.set_adapter(adapter)

      register_sg = Kakine::Resource.load_security_group_by_yaml(filename, options[:tenant])
      current = Kakine::Resource.get_current(options[:tenant])

      diffs.each do |diff|
        security_groups <<  Kakine::SecurityGroup.new(options[:tenant], diff)
      end

      security_groups.each do |sg|
        if sg.update_rule? # foo[2]
          case
          when sg.add?
            operation.create_security_rule(sg)
          when sg.delete?
            operation.delete_security_rule(sg)
          when sg.update_attr?
            pre_sg = sg.get_prev_instance
            operation.delete_security_rule(pre_sg)
            delay_create << sg # avoid duplication entry
          else
            raise
          end
        else # foo
          case
          when sg.add?
            security_group_id = operation.create_security_group(sg)
            operation.create_security_rule(sg, security_group_id)
          when sg.delete?
            operation.delete_security_group(sg)
          when sg.update_attr?
            operation.delete_security_group(sg)
            security_group_id = operation.create_security_group(sg)
            operation.create_security_rule(sg, security_group_id)
          else
            raise
          end
        end
      end
      # update rule attributes delay create
      delay_create.each do |sg|
        operation.create_security_rule(sg)
      end
    end
  end
end

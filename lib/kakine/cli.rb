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
      adapter = if options[:dryrun]
        Kakine::Adapter::Mock.new
      else
        Kakine::Adapter::Real.new
      end

      operation = Kakine::CLI::Operation.new
      operation.set_adapter(adapter)

      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"

      security_groups = []
      delay_create = []

      diffs = HashDiff.diff(
        Kakine::Resource.security_groups_hash(options[:tenant]),
        Kakine::Resource.yaml(filename)
      )

      diffs.each do |diff|
        security_groups <<  Kakine::SecurityGroup.new(options[:tenant], diff)
      end

      security_groups.each do |sg|
        if sg.is_update_rule? # foo[2]
          case
          when sg.is_add?
            operation.create_security_rule(sg)
          when sg.is_delete?
            operation.delete_security_rule(sg)
          when sg.is_update_attr?
            pre_sg = sg.get_prev_instance
            operation.delete_security_rule(pre_sg)
            delay_create << sg # avoid duplication entry
          else
            raise
          end
        else # foo
          case
          when sg.is_add?
            security_group_id = operation.create_security_group(sg)
            operation.create_security_rule(sg, security_group_id)
          when sg.is_delete?
            operation.delete_security_group(sg)
          when sg.is_update_attr?
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

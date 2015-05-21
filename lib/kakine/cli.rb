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
      security_groups = []
      delay_create = []

      adapter = if options[:dryrun]
        Kakine::Adapter::Mock.new
      else
        Kakine::Adapter::Real.new
      end

      operation = Kakine::CLI::Operation.new
      operation.set_adapter(adapter)

      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"
      load_sg = Kakine::Resource.yaml(filename)

      return unless Kakine::Validate.validate_file_input(load_sg)

      diffs = HashDiff.diff(
        Kakine::Resource.security_groups_hash(options[:tenant]),
        load_sg
      ).sort.reverse

      diffs.each do |diff|
        security_groups <<  Kakine::SecurityGroup.new(options[:tenant], diff)
      end

      begin
        security_groups.each do |sg|
          if sg.update_rule? # foo[2]
            case
            when sg.add?
              operation.create_security_rule(sg)
            when sg.delete?
              operation.delete_security_rule(sg)
            when sg.update_attr?
              operation.delete_security_rule(sg.get_prev_instance)
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
            when sg.delete_all_rules?
              operation.delete_security_rule(sg.get_prev_instance)
            else
              raise
            end
          end
        end
        # update rule delay create
        delay_create.each do |sg|
          operation.create_security_rule(sg)
        end

      rescue Excon::Errors::Conflict => e
        JSON.parse(e.response[:body]).each { |e,m| puts "#{e}:#{m["message"]}" }
      end
    end
  end
end

require 'kakine'

module Kakine
  class CLI < Thor

    option :tenant, type: :string, aliases: '-t'
    desc 'show', 'show Security Groups specified tenant'
    def show
      puts Kakine::Resource.get(:openstak).security_groups_hash(options[:tenant]).to_yaml
    end

    option :tenant, type: :string, aliases: "-t"
    option :dryrun, type: :boolean, aliases: "-d"
    option :filename, type: :string, aliases: "-f"
    desc 'apply', "apply local configuration into OpenStack"
    def apply
      filename = options[:filename] ? options[:filename] : "#{options[:tenant]}.yaml"
      Kakine::Adapter.set_option(options[:dryrun])

      current_security_groups  = Kakine::Resource.get(:openstack).load_security_group(options[:tenant])
      new_security_groups      = Kakine::Resource.get(:yaml).load_security_group(filename, options[:tenant])

      new_security_groups.each do |new_sg|
        registered_sg  = current_security_groups.find { |cur_sg| cur_sg.name == new_sg.name }
        if registered_sg
          new_sg.convergence!(registered_sg) if new_sg != registered_sg
        else
          Kakine::Builder.create_security_group(new_sg)
          new_sg.rules.each do |rule| 
            Kakine::Builder.create_security_rule(new_sg.tenant_name, new_sg.name, rule)
          end if new_sg.has_rules?
        end
      end

      current_security_groups.each do |current_sg|
        Kakine::Builder.delete_security_group(current_sg) if new_security_groups.none? { |new_sg| current_sg.name == new_sg.name }
      end
    rescue Kakine::Errors => e
      puts "[error] #{e}"
    end
  end
end

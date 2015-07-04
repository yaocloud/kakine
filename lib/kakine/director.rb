module Kakine
  class Director
    class << self
      def show_current_security_group
        puts Kakine::Resource.get(:openstack).security_groups_hash.to_yaml
      end

      def apply
        current_sgs = Kakine::Resource.get(:openstack).load_security_group
        new_sgs     = Kakine::Resource.get(:yaml).load_security_group

        new_sgs.each do |new_sg|
          if already_sg = already_setup(current_sgs, new_sg)
            Kakine::Builder.convergence_security_group(new_sg, already_sg) if new_sg != already_sg
          else
            create_new_security_group(new_sg)
          end
        end

        clean_up_security_group(current_sgs, new_sgs)

        rescue Kakine::Errors => e
          puts "[error] #{e}"
      end

      def already_setup(current_sgs, new_sg)
        current_sgs.find { |current_sg| current_sg.name == new_sg.name }
      end

      def create_new_security_group(new_sg)
        Kakine::Builder.create_security_group(new_sg)
        new_sg.rules.each do |rule|
          Kakine::Builder.create_security_rule(new_sg.tenant_name, new_sg.name, rule)
        end if new_sg.has_rules?
      end

      def clean_up_security_group(current_sgs, new_sgs)
        current_sgs.each do |current_sg|
          Kakine::Builder.delete_security_group(current_sg) if new_sgs.none? { |new_sg| current_sg.name == new_sg.name }
        end
      end
    end
  end
end

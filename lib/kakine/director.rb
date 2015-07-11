module Kakine
  class Director
    class << self
      def show_current_security_group
        Kakine::Builder.show_security_groups
      end

      def apply
        current_sgs = Kakine::Resource.get(:openstack).load_security_group
        new_sgs     = Kakine::Resource.get(:yaml).load_security_group
        new_sgs.each do |new_sg|
          if already_sg = Kakine::Builder.already_setup(new_sg, current_sgs)
            Kakine::Builder.convergence_security_group(new_sg, already_sg) if new_sg != already_sg
          else
            Kakine::Builder.create_new_security_group(new_sg)
          end
        end

        Kakine::Builder.clean_up_security_group(new_sgs, current_sgs)

        rescue Kakine::Errors => e
          puts "[error] #{e}"
      end
    end
  end
end

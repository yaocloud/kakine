module Kakine
  class Director
    class << self
      def show_current_security_group
        puts Kakine::Builder.security_groups
      end

      def apply
        current_sgs = Kakine::Resource.get(:openstack).load_security_group
        new_sgs     = Kakine::Resource.get(:yaml).load_security_group
        new_sgs.each do |new_sg|
          if already_sg = Kakine::Builder.already_setup_security_group(new_sg, current_sgs)
            Kakine::Builder.convergence_security_group(new_sg, already_sg) if new_sg != already_sg
          else
            Kakine::Builder.first_create_security_group(new_sg)
          end
        end

        Kakine::Builder.clean_up_security_group(new_sgs, current_sgs)

      rescue Kakine::Error => e
        puts "[error] #{e}"
      end

      def convert(format, output = nil)
        sgs = Kakine::Resource.get(:yaml).load_security_group

        file = output ? open(output, 'w') : $stdout.dup
        begin
          exporter = Kakine::Exporter.get(format).new(file)
          exporter.export(sgs)
        ensure
          file.close
        end
      end
    end
  end
end

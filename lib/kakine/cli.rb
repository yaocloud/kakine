module Kakine
  class CLI < Thor

    option :tenant, type: :string, aliases: '-t'
    desc 'show', 'show Security Groups specified tenant'
    def show
      setup(options)
      Kakine::Director.show_current_security_group
    end

    option :tenant, type: :string, aliases: "-t"
    option :dryrun, type: :boolean, aliases: "-d"
    option :filename, type: :string, aliases: "-f"
    desc 'apply', "apply local configuration into OpenStack"
    def apply
      setup(options)
      Kakine::Director.apply
    end

    option :tenant, type: :string, aliases: "-t"
    option :filename, type: :string, aliases: "-f"
    option :format, type: :string, aliases: '-F'
    option :output, type: :string, aliases: '-o'
    desc 'convert', 'convert Security Groups into other format'
    def convert
      format = options[:format] or fail '--format is required'
      output = options[:output]
      Kakine::Option.set_options(options)
      Kakine::Director.convert(format, output)
    end

    no_commands do
      def setup(options)
        Kakine::Option.set_options(options)
        Kakine::Config.setup unless ENV['RACK_ENV'] == 'test'
      end
    end
  end
end

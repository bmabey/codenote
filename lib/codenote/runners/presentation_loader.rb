require 'codenote/presentation_loader'
require 'optparse'

module CodeNote
  module Runners
    class PresentationLoader

      def self.run(args, out_stream = STDOUT, error_stream = STDERR)
        PresentationLoader.new(args, out_stream, error_stream).run
      end

      def initialize(args, out_stream, error_stream)
        @args, @out_stream, @error_stream = args, out_stream, error_stream
      end

      def run
        opts = OptionParser.new
        opts.banner = "Usage: codenote [presentation to load and serve]\n\n"

        opts.separator "Options:"
        opts.on_tail("-h", "--help", "You're looking at it.") do
          @out_stream.puts opts.help
          return Kernel.exit(0)
        end

        opts.parse!(@args)

        CodeNote::PresentationLoader.setup(presentation_file)
      end

      private

      def exit_with(message, error_code = 1)
        @error_stream.puts message
        Kernel.exit error_code
      end

      def presentation_file
        file_name = @args.last
        File.read(file_name)
      rescue Errno::ENOENT
        exit_with("There is no file named '#{file_name}' to load!")
      end

    end
  end
end

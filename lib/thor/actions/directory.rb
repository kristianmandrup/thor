require 'thor/actions/helpers/directory'

class Thor
  module Actions
    module Directory

      # Copies recursively the files from source directory to root directory.
      # If any of the files finishes with .tt, it's considered to be a template
      # and is placed in the destination without the extension .tt. If any
      # empty directory is found, it's copied and all .empty_directory files are
      # ignored. Remember that file paths can also be encoded, let's suppose a doc
      # directory with the following files:
      #
      #   doc/
      #     components/.empty_directory
      #     README
      #     rdoc.rb.tt
      #     %app_name%.rb
      #
      # When invoked as:
      #
      #   directory "doc"
      #
      # It will create a doc directory in the destination with the following
      # files (assuming that the app_name is "blog"):
      #
      #   doc/
      #     components/
      #     README
      #     rdoc.rb
      #     blog.rb
      #
      # ==== Parameters
      # source<String>:: the relative path to the source root.
      # destination<String>:: the relative path to the destination root.
      # config<Hash>:: give :verbose => false to not log the status.
      #                If :recursive => false, does not look for paths recursively.
      #
      # ==== Examples
      #
      #   directory "doc"
      #   directory "doc", "docs", :recursive => false
      #
      def directory(source, destination=nil, config={}, &block)
        action Helpers::Directory.new(self, source, destination || source, config, &block)
      end

      # Creates an empty directory.
      #
      # ==== Parameters
      # destination<String>:: the relative path to the destination root.
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Examples
      #
      #   empty_directory "doc"
      #
      def empty_directory(destination, config={})
        action Helpers::EmptyDirectory.new(self, destination, config)
      end



    end
  end
end

require 'thor/actions/helpers/create_file'

class Thor
  module Actions
    module File
      # Create a new file relative to the destination root with the given data,
      # which is the return value of a block or a data string.
      #
      # ==== Parameters
      # destination<String>:: the relative path to the destination root.
      # data<String|NilClass>:: the data to append to the file.
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Examples
      #
      #   create_file "lib/fun_party.rb" do
      #     hostname = ask("What is the virtual hostname I should use?")
      #     "vhost.name = #{hostname}"
      #   end
      #
      #   create_file "config/apach.conf", "your apache config"
      #
      def create_file(destination, data=nil, config={}, &block)
        action Helpers::CreateFile.new(self, destination, block || data.to_s, config)
      end
      alias :add_file :create_file   
      
      # Copies the file from the relative source to the relative destination. If
      # the destination is not given it's assumed to be equal to the source.
      #
      # ==== Parameters
      # source<String>:: the relative path to the source root.
      # destination<String>:: the relative path to the destination root.
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Examples
      #
      #   copy_file "README", "doc/README"
      #
      #   copy_file "doc/README"
      #
      def copy_file(source, destination=nil, config={}, &block)
        destination ||= source
        source = File.expand_path(find_in_source_paths(source.to_s))

        create_file destination, nil, config do
          content = File.binread(source)
          content = block.call(content) if block
          content
        end
      end

      # Gets the content at the given address and places it at the given relative
      # destination. If a block is given instead of destination, the content of
      # the url is yielded and used as location.
      #
      # ==== Parameters
      # source<String>:: the address of the given content.
      # destination<String>:: the relative path to the destination root.
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Examples
      #
      #   get "http://gist.github.com/103208", "doc/README"
      #
      #   get "http://gist.github.com/103208" do |content|
      #     content.split("\n").first
      #   end
      #
      def get(source, destination=nil, config={}, &block)
        source = File.expand_path(find_in_source_paths(source.to_s)) unless source =~ /^http\:\/\//
        render = open(source).binmode.read

        destination ||= if block_given?
          block.arity == 1 ? block.call(render) : block.call
        else
          File.basename(source)
        end

        create_file destination, render, config
      end
      
      # Embeds the contents of a file into an existing file 
      # ==== Parameters
      # source<String>:: the relative path to the source root.
      # indent<String>:: the indentation string, fx '    '
      #
      # ==== Examples
      #   # typically used from inside a template
      #   file_content "authors"
      #
      #   file_content "authors", '    '
      def file_content(source, indent='')
        IO.read(File.join(self.class.source_root, source)).gsub(/^/, indent)
      end

      # Changes the mode of the given file or directory.
      #
      # ==== Parameters
      # mode<Integer>:: the file mode
      # path<String>:: the name of the file to change mode
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Example
      #
      #   chmod "script/*", 0755
      #
      def chmod(path, mode, config={})
        return unless behavior == :invoke
        path = File.expand_path(path, destination_root)
        say_status :chmod, relative_to_original_destination_root(path), config.fetch(:verbose, true)
        FileUtils.chmod_R(mode, path) unless options[:pretend]
      end



      # Removes a file at the given location.
      #
      # ==== Parameters
      # path<String>:: path of the file to be changed
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Example
      #
      #   remove_file 'README'
      #   remove_file 'app/controllers/application_controller.rb'
      #
      def remove_file(path, config={})
        return unless behavior == :invoke
        path  = File.expand_path(path, destination_root)

        say_status :remove, relative_to_original_destination_root(path), config.fetch(:verbose, true)
        ::FileUtils.rm_rf(path) if !options[:pretend] && File.exists?(path)
      end
      alias :remove_dir :remove_file
 
                  
    end
  end
end
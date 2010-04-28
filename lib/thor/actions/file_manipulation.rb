require 'erb'
require 'open-uri'

require 'thor/actions/helpers/inject_into_file'

class Thor
  module Actions
    module FileManipulation  
      # Injects the given content into a file. Different from gsub_file, this
      # method is reversible.
      #
      # ==== Parameters
      # destination<String>:: Relative path to the destination root
      # data<String>:: Data to add to the file. Can be given as a block.
      # config<Hash>:: give :verbose => false to not log the status and the flag
      #                for injection (:after or :before) or :force => true for 
      #                insert two or more times the same content.
      # 
      # ==== Examples
      #
      #   inject_into_file "config/environment.rb", "config.gem :thor", :after => "Rails::Initializer.run do |config|\n"
      #
      #   inject_into_file "config/environment.rb", :after => "Rails::Initializer.run do |config|\n" do
      #     gems = ask "Which gems would you like to add?"
      #     gems.split(" ").map{ |gem| "  config.gem :#{gem}" }.join("\n")
      #   end
      #
      def inject_into_file(destination, *args, &block)      
        data = block_given? ? block : args.shift      
        data = "#{data}\n" if args.has_key? :newline
        action Helpers::InjectIntoFile.new(self, destination, data, args.shift)
      end      
      
      # Prepend text to a file. Since it depends on inject_into_file, it's reversible.
      #
      # ==== Parameters
      # path<String>:: path of the file to be changed
      # data<String>:: the data to prepend to the file, can be also given as a block.
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Example
      #
      #   prepend_file 'config/environments/test.rb', 'config.gem "rspec"'
      #
      #   prepend_file 'config/environments/test.rb', 'config.gem "rspec"', :newline
      #
      #   prepend_file 'config/environments/test.rb', :newline, :not_verbose do
      #     'config.gem "rspec"'
      #   end
      #
      def prepend_file(path, *args, &block)
        config = parse_args(args)
        config.merge!(:after => /\A/)  
        inject_into_file(path, *(args << config), &block)
      end

      # Append text to a file. Since it depends on inject_into_file, it's reversible.
      #
      # ==== Parameters
      # path<String>:: path of the file to be changed
      # data<String>:: the data to append to the file, can be also given as a block.
      # config<Hash>:: give :verbose => false to not log the status. :newline => true to ensure new line after text. Can also be given as symbols :newline, :not_verbose
      #
      # ==== Example
      #
      #   append_file 'config/environments/test.rb', 'config.gem "rspec"', :newline
      #
      #   append_file 'config/environments/test.rb' do
      #     'config.gem "rspec"'
      #   end
      #
      def append_file(path, *args, &block)
        config = parse_args(args)
        config.merge!(:before => /\z/)
        inject_into_file(path, *(args << config), &block)
      end

      # Run a regular expression replacement on a file.
      #
      # ==== Parameters
      # path<String>:: path of the file to be changed
      # flag<Regexp|String>:: the regexp or string to be replaced
      # replacement<String>:: the replacement, can be also given as a block
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Example
      #
      #   gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'
      #
      #   gsub_file 'README', /rake/, :green do |match|
      #     match << " no more. Use thor!"
      #   end
      #
      def gsub_file(path, flag, *args, &block)
        return unless behavior == :invoke
        config = args.last.is_a?(Hash) ? args.pop : {}

        path = File.expand_path(path, destination_root)
        say_status :gsub, relative_to_original_destination_root(path), config.fetch(:verbose, true)

        unless options[:pretend]
          content = File.binread(path)
          content.gsub!(flag, *args, &block)
          File.open(path, 'wb') { |file| file.write(content) }
        end
      end

      protected
        def parse_args(*args)
          arguments = {}
          args.each do |arg| 
            case arg
            when Symbol
              if arg == :not_verbose
                arguments.merge!(:verbose => false)            
              else
                arguments.merge!(arg => true)
              end
            when Hash
              arguments.merge!(arg)
            end        
          end
          arguments
        end

    end
  end
end
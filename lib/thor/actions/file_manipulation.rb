require 'erb'
require 'open-uri'

class Thor
  module Actions

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

    # Gets an ERB template at the relative source, executes it and makes a copy
    # at the relative destination. If the destination is not given it's assumed
    # to be equal to the source removing .tt from the filename.
    #
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   template "README", "doc/README"
    #
    #   template "doc/README"
    #
    def template(source, destination=nil, config={}, &block)
      destination ||= source
      source  = File.expand_path(find_in_source_paths(source.to_s))
      context = instance_eval('binding')

      create_file destination, nil, config do
        content = ERB.new(::File.binread(source), nil, '-').result(context)
        content = block.call(content) if block
        content
      end
    end

    # Embeds the contents of a file into an existing file 
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # indent<String>:: the indentation string, fx '    '
    #
    # ==== Examples
    #
    #   embed_file "authors"
    #
    #   embed_file "authors", '    '
    def embed_file(source, indent='')
      IO.read(File.join(self.class.source_root, source)).gsub(/^/, indent)
    end

    # Embeds the contents of running a template into an existing file
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # indent<String>:: the indentation string, fx '    '
    #
    # ==== Examples
    #
    #   embed_template "README"
    #
    #   embed_template "README", '    '     
    def embed_template(source, indent='')
      template = File.join(self.class.source_root, source)
      ERB.new(IO.read(template), nil, '-').result(binding).gsub(/^/, indent)
    end

    # Cleans up a Gemfile by inserting missing newlines between gem statements
    # Fixes old 'bug', where gem statements would be inserted into Gemfile without newlines
    # ==== Examples
    #
    # cleanup_gemfile    
    def cleanup_gemfile
      # add newline between each gem statement in Gemfile
      gsub_file 'Gemfile', /('|")gem/, "\1\ngem"      
    end

    # Determine if there is a gem statement in a text for a certain gem
    # ==== Parameters
    # text<String>:: text to search for gem statement
    # gem_name<String>:: name of gem to search for
    # ==== Examples
    #
    # has_gem? 'rspec' 
    
    # Note: Should allow for gem version.
    # Should instead use ruby_traverser_dsl (gem on github) which uses ripper2ruby
    def has_gem?(text, gem_name)        
      if /\n[^#]*gem\s*('|")\s*#{Regexp.escape(gem_name)}\s*\1/i.match(text)  
        true 
      else
        false
      end      
    end

    # Determine if a certain plugin is installed in its appropriate location
    # ==== Parameters
    # plugin_name<String>:: plugin name
    # ==== Examples
    #
    # has_plugin? 'paginator' 
    def has_plugin?(plugin_name) 
      File.directory?(File.join(Rails.root, "vendor/plugins/#{plugin_name}"))
    end

    # Quick helper for adding a single gem statement to the Gemfile
    # ==== Parameters
    # gem_name<String>:: gem name
    # gem_version<String>:: gem version string
    # ==== Examples
    #
    #   add_gem 'rspec' 
    #   add_gem 'rspec', '>= 2.0' 
    def add_gem(gem_name, gem_version = nil)
      if !has_gem?(gemfile_txt, gem_name) 
        gem_version_str = gem_version ? ", '#{gem_version}'" : '' 
        append_line_to_file 'Gemfile', "gem '#{gem_name}'#{gem_version_str}"  
      end
    end

    # Quick helper for adding multiple gem statements to the Gemfile
    # ==== Parameters
    # gem_names<String>:: list of gem names to add
    #
    # ==== Examples
    #
    #   add_gems 'rspec', 'cucumber', 'mocha'
    def add_gems(*gem_names)
      gem_names.each{|gem_name| add_gem(gem_name) }
    end

    # Loads and caches the current Gemfile content
    def gemfile_txt
      @gemfile_txt ||= File.open('Gemfile').read        
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
    #   prepend_file 'config/environments/test.rb' do
    #     'config.gem "rspec"'
    #   end
    #
    def prepend_file(path, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config.merge!(:after => /\A/)
      inject_into_file(path, *(args << config), &block)
    end

    # Append text to a file. Since it depends on inject_into_file, it's reversible.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # data<String>:: the data to append to the file, can be also given as a block.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Example
    #
    #   append_file 'config/environments/test.rb', 'config.gem "rspec"'
    #
    #   append_file 'config/environments/test.rb' do
    #     'config.gem "rspec"'
    #   end
    #
    def append_file(path, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config.merge!(:before => /\z/)
      inject_into_file(path, *(args << config), &block)
    end

    # Injects text right after the class definition. Since it depends on
    # inject_into_file, it's reversible.
    #
    # ==== Parameters
    # path<String>:: path of the file to be changed
    # klass<String|Class>:: the class to be manipulated
    # data<String>:: the data to append to the class, can be also given as a block.
    # config<Hash>:: give :verbose => false to not log the status.
    #
    # ==== Examples
    #
    #   inject_into_class "app/controllers/application_controller.rb", "  filter_parameter :password\n"
    #
    #   inject_into_class "app/controllers/application_controller.rb", ApplicationController do
    #     "  filter_parameter :password\n"
    #   end
    #
    def inject_into_class(path, klass, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      config.merge!(:after => /class #{klass}\n|class #{klass} .*\n/)
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

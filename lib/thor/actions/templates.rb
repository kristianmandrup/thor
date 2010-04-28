class Thor
  module Actions 
    module Templates

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
    

      # Embeds the contents of running a template into an existing file
      # ==== Parameters
      # source<String>:: the relative path to the source root.
      # indent<String>:: the indentation string, fx '    '
      #
      # ==== Examples
      #   # typically used from inside a template
      #   template_content "README"
      #
      #   template_content "README", '    '     
      def template_content(source, indent='')
        template = File.join(self.class.source_root, source)
        ERB.new(IO.read(template), nil, '-').result(binding).gsub(/^/, indent)
      end
    

      # TODO: use find_in_source_paths somehow! (Jose Valim suggestion)
    
      # find local template path
      # first tries $PRJ_ROOT/lib/templates then simply $PRJ_ROOT/templates
      def local_template_path(file, args = 'templates')
        action Helpers::LocalTemplates.new(file, args.shift)
      end

      # get the template path
      # use the thor template repo at THOR_TEMPLATE_PATH if it is configured otherwise use a local default
      def repo_template_path(file, args = 'templates')
        action Helpers::RepoTemplates.new(file, args.shift)
      end

      # calculate the template_path of a remote repository
      def remote_template_path(file, *args)
        args << 'templates' if args.empty?
        template_dir = args.shift              
      
        action Helpers::Templates.new(file, template_dir)
      end
    end
  end
end
module Thor
  module RunTask
    module Install
      module Util  
        def display_task_content(contents)
          unless options["force"] || options[:verbose]
            say "Your Thorfile contains:"
            say contents        
            return false if no?("Do you wish to continue [y/N]?")
          end
        end        

        # all this 'as' stuff should be refactored!!!
        def configure_as(content)
          # set the as instance variable for later 
          install_as contents
          # let user specify the as name
          specify_as_name

          {
            :filename   => Digest::MD5.hexdigest(name + as),
            :location   => location,
            :namespaces => Thor::Util.namespaces_in_content(contents, base)
          }
        end

        def install_as
          @as ||= options["as"] || begin
            first_line = contents.split("\n")[0]
            (match = first_line.match(/\s*#\s*module:\s*([^\n]*)/)) ? match[1].strip : nil
          end
        end

        def specify_as_name
          unless as
            basename = File.basename(name) 
            as_name = basename.gsub /\.thor$/, ''      
            @as = ask("Please specify a name for #{name} in the system repository [#{as_name}]:")
            @as = as_name if as.empty?
          end
        end        
        
        def location
          @location ||= if options[:relative] || name =~ /^http:\/\//
            name
          else
            File.expand_path(name)
          end
        end                

        def dir?(name)
          File.directory(name) ? name : nil
        end

        def lib_dir?
          File.directory?('lib')   
        end

        def say_verbose(msg)
          say msg if options[:verbose]
        end
      end
    end
  end
end

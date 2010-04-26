module Thor
  module RunTask
    module Install
      module TaskFinder   
        attr_accessor :base, :package, :contents        
        
        def thor_tasks(names)
          begin       
            thor_names!(names)  
            say_verbose "Installing thor task: #{name}"  
            read_package(name) if package?
            read_file(name) if !package?
            return [contents, base, package]            
          rescue OpenURI::HTTPError
            raise Error, "Error opening URI '#{name}'"
          rescue Errno::ENOENT
            raise Error, "Error opening file '#{name}'"
          rescue
            raise Error, "Error installing thor task '#{name}'"      
          end
        end

        def package?(name)
          File.directory?(File.expand_path(name))          
        end

        def read_package(name)
          base, package = File.join(name, 'main.thor'), :directory
          contents      = open(base).read         
        end

        def read_file(name)
          base, package = name, :file
          contents      = open(name).read
        end

        def thor_name(name)
          if !name || name.strip == ''
            # lib takes precedence
            thor_files = FileList['lib/*.thor', '*.thor']
            if thor_files
              thor_files.reject!{|f| !File.exist?(f)}
              # ensure no duplicates
              thor_files.uniq!
              name = thor_files.first
            end

          end
        end

        # tries to find thor files both in the project root and in the /lib directory (ruby convention)
        def thor_names(*names)
          names.select{|name| thor_name(name)}
          raise Error, "No .thor file found in current dir or in lib" if !names                        
        end
      end
    end
  end
end
module Thor
  module RunTask
    module Install
      module TaskFinder   
        attr_accessor :base, :package, :contents        
        
        def get_thor_task(name)
          begin       
            thor_name!(name)
  
            say "Installing thor task: #{name}" if options[:verbose]
            if File.directory?(File.expand_path(name))
              base, package = File.join(name, 'main.thor'), :directory
              contents      = open(base).read         
            else
              base, package = name, :file
              contents      = open(name).read
            end
            return [contents, base, package]            
          rescue OpenURI::HTTPError
            raise Error, "Error opening URI '#{name}'"
          rescue Errno::ENOENT
            raise Error, "Error opening file '#{name}'"
          rescue
            raise Error, "Error installing thor task '#{name}'"      
          end
        end

        def thor_name!(name)
          if !name || name.strip == ''
            thor_files = FileList['*.thor', 'lib/*.thor']
            if thor_files
              thor_files.reject!{|f| !File.exist?(f)}
              thor_files.uniq!
              name = thor_files.first
            end
            raise Error, "No .thor file found in current dir or in lib" if !name              
          end
        end
      end
    end
  end
end
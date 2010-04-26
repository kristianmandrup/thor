require 'tmpdir'

module Thor
  module RunTask
    module Install
      module TaskFinder   
        attr_accessor :tasks

        # get collection of all thor tasks available 
        # if names given filter collection by name   
        # TODO: allow to retrieve from repo     
        def find_thor_tasks(names)
          begin       
            tasks = all_thor_tasks
            filter_thor_tasks!(names) if names            
        end

        def all_thor_tasks          
          build_tasks          
        end

        def build_tasks
          @tasks = []
          thor_files.each do |file|
            tasks << build_task(f)             
          end
        end

        def thor_files
          return remote_thor_files if options[:repo]                           
          get_thor_files
        end

        def get_thor_files
          # lib takes precedence          
          thor_files = thor_file_list
          raise Error, "No .thor files found in current dir or in lib" if !thor_files              
          thor_files.reject!{|f| !File.exist?(f)}
          # ensure no duplicates
          thor_files.uniq!
        end
        
        def thor_file_list
          FileList['lib/*.thor', '*.thor']
        end

        # TODO: If caching is enabled, deploy local copy in repository, otherwise point directly to each entry in the remote repo
        def remote_thor_files                          
          begin
            Dir.tmpdir do                     
              # create temporary directory  
              `git clone #{options[:repo]}`  
              # clone repository here            
              return get_thor_files if !thor_file_list.empty?
              iterate_thor_repo
            end          
            rescue 
              raise Error, "Error accessing repo '#{options[:repo]}'"
          end
        end

        def iterate_thor_repo
          Dir.foreach('.') do |entry|
            if entry.directory?
              Dir.chdir(entry) do
                get_thor_files                  
              end    
            end
          end
        end

        def filter_thor_tasks(names)
          tasks.reject! do |task| 
            if !names.include?(task.name)
              say "No .thor file #{name} found in current dir or in lib"
              false
            else
              true
            end  
          end
        end

        def build_task(file)
          begin
            task = TaskObj.new :base => file  
            # try to read task to see if it is accessible
            task.contents
            task
            rescue OpenURI::HTTPError
              raise Error, "Error opening URI '#{name}'"
            rescue Errno::ENOENT
              raise Error, "Error opening file '#{name}'"
            rescue
              raise Error, "Error retrieving thor task '#{name}'"      
            end
          end
        end
               
      end
    end
  end
end
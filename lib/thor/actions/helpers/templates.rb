class Thor
  module Action
    module Helpers

      # Enable a config file for Thor where you can set various defaults for repository locations
      # Alternative is to use environment variables
      class Config
        def self.place(name)
          config_file_entry(name) || ENV["THOR_TEMPLATE_PATH_#{name}"]
        end

        def self.config_file
          File.join(thor_root, 'thor_config.yml')
        end
  
        def self.config_file_entry(name)
          yaml = YAML.load_file(config_file) 
          yaml.each_pair do |entry, value|
            return value if entry == name
          end
          nil
        end
      end

      class Templates
        def local_template_path(file, templates_dir = 'templates')
          path = File.dirname(file)
          # try /templates relative to thor_file
          templates_path = File.join(path, templates_dir)
          return templates_path if File.directory?(templates_path)                
          raise "Templates directory #{templates_dir} not found at #{path}"
        end

        def template_path(task_name, templates_dir)
          File.join(base_template_path, task_name, templates_dir)
        end

        def non_local_path(file, templates_dir, place)
          task_name = TaskName.new.retrieve(file)
          @base_template_path = ENV["THOR_TEMPLATE_PATH_#{place}"]
          base_template_path ? template_path(task_name, templates_dir) : local_template_path(file)
        end

        # TODO: Refactor!
        def strip_last_lib(path)
          path.reverse.sub(/^bil\//, '').reverse
        end
        
      end

      class RemoteTemplates < Templates
        attr_accessor :base_template_path
  
        def initialize(file, templates_dir)        
          non_local_path(file, templates_dir, 'REMOTE_REPO')
        end

      end

      class RepoTemplates < Templates

        def initialize(file, templates_dir)        
          non_local_path(file, templates_dir, 'LOCAL_REPO')
        end
      end

      class LocalTemplates < Templates
        
        def initialize(file, templates_dir)        
          local_template_path(file, templates_dir)
        end    
      end
      
      class TaskName
        attr_accessor :task_name

        def matching_file_entry?(key, value, file)
          key.to_s == 'filename' && File.basename(value.to_s) == file
        end

        # find thor task name in .thor repo matching filename
        def yaml_task_name(file)     
          thor_yml_file = thor_yml(file)
          return task_name_from_yaml(thor_yml_file) if File.exists?(thor_yml_file)      
          raise "No thor.yml index file found in thor repo"          
        end

        # find location of thor_file based on location of file_pointer for thor task being executed
        def thor_yml_file(file)
          file = File.basename(file.to_s)        
          File.join(File.dirname(file), 'thor.yml')          
        end

        # find task_name for the thor task being executed by finder entry with matching file_pointer entry!
        # is there a better way!?
        def task_name_from_yaml(thor_yml_file) 
          yaml = YAML.load_file(thor_yml_file) 
          yaml.each_pair do |task_key, task|
            task.each_pair do |key, value|
                return task_key.gsub(/\.thor$/, '') if matching_file_entry?(key, value, file)
            end
          end
          raise "No entry found for #{file} in thor.yml, the index for thor repo"
        end

        # get thor task name for a file 
        def retrieve(file)
          dir_name = File.dirname(file)
          dir_base_name = File.basename(dir_name)
          unless task_name
            if dir_base_name == '.thor'
              task_name ||= yaml_task_name(file)
            else
              task_dir_name = strip_last_lib(dir_name)
              task_name ||= File.basename(task_dir_name)
            end
          end
        end
      end      
    end
  end
end
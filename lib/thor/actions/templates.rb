class Thor
  module Actions

    # TODO: use find_in_source_paths somehow!
    # Needs redesign!

    attr_accessor :task_name

    # find local template path
    # first tries $PRJ_ROOT/lib/templates then simply $PRJ_ROOT/templates
    def local_template_path(file, templates_dir = 'templates')
      path = File.dirname(file)
      # try fx $PRJ_ROOT/lib/templates
      lib_templates = File.join(path, templates_dir)
      return lib_templates if File.directory?(lib_templates)                
      # strip away any /lib/ from path and try fx $PRJ_ROOT/templates
      task_dir_name = path.reverse.sub(/^bil\//, '').reverse        
      File.join(task_dir_name, templates_dir)
    end

    def template_repo_task_path(task_name, templates_dir)
      File.join(ENV['THOR_TEMPLATE_PATH'], task_name, templates_dir)
    end

    # get the template path
    # use the thor template repo at THOR_TEMPLATE_PATH if it is configured otherwise use a local default
    def template_path(file, templates_dir = 'templates')
      task_name = get_task_name(file)
      ENV['THOR_TEMPLATE_PATH'] ? template_repo_task_path(task_name, templates_dir) : local_template_path(file)
    end
    
    protected

    # find thor task name in .thor repo matching filename
    def yaml_task_name(dir_name, file)
      file = File.basename(file.to_s)
      thor_yml_file = File.join(dir_name, 'thor.yml')          
      if File.exists?(thor_yml_file)
        yaml = YAML.load_file(thor_yml_file) 
        yaml.each_pair do |task_key, task|
          task.each_pair do |key, value|
            if 'filename' == key.to_s                
              val = File.basename(value.to_s)                           
              return task_key.gsub(/\.thor$/, '') if val == file
            end
          end
        end
      end
      raise "No entry found for #{file} in thor.yml in ~/.thor"
    end

    # get thor task name for a file 
    def get_task_name(file)
      dir_name = File.dirname(file)
      dir_base_name = File.basename(dir_name)
      unless task_name
        if dir_base_name == '.thor'
          task_name ||= yaml_task_name(dir_name, file)
        else
          task_dir_name = dir_name.reverse.sub(/^bil\//, '').reverse
          task_name ||= File.basename(task_dir_name)
        end
      end
    end
    
  end
end
module Thor
  module TemplateUtil   
    def create_template_repo_dir          
      FileUtils.mkdir_p template_repo if !File.directory?(template_repo)
      copy_templates_to_repo
    end

    def copy_templates_to_repo
      FileUtils.mkdir_p template_repo_dir              
      FileUtils.cp_r(task_template_dir, template_repo_dir)
    end    
    
    # Note: ensure as_name is a def
    def template_repo_dir
      @template_repo_dir ||= File.join(template_repo, as_name)
    end

    def task_template_dir
      # by default expects templates dir in root of thor task, override this with --templates option
      @task_template_dir ||= dir?(template_dir) || dir?(lib_template_dir)
    end

    def template_repo
      @template_repo ||= template_path || default_template_path            
    end

    protected

    def template_dir
      @template_dir ||= options["templates"] ? options["templates"] : 'templates'    
    end

    def lib_template_dir
      @lib_template_dir ||= File.join('lib', template_dir)      
    end

    def template_path 
      ENV['THOR_TEMPLATE_PATH'] 
    end

    def default_template_path
      File.join(ENV['HOME'], 'thor-templates')
    end
  end
end    

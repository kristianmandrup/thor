# Deploying templates is designed to play well with the new template_path and local_template_path action helpers (see actions.rb)

require 'thor/run_tasks/install/deployment/template_util'

module Thor
  module RunTask
    module Install
      module DeployTemplates
        include Thor::TemplateUtil
        
        def do_deploy_templates?
          !(name =~ /^http:\/\//) && options["deploy-templates"] && task_template_dir
        end

        def deploy_templates               
          if !template_path
            say "You can set the environment variable THOR_TEMPLATE_PATH to point to a dir that acts as a template repository for all thor tasks."      
            say "This template repository must reside outside the thor root repository: #{thor_root}"                  
          end

          create_template_repo_dir              

          say_verbose "Deployed templates in #{task_template_dir} to #{template_repo}"
        end         
      end
    end
  end
end

require 'thor/run_tasks/install/deployment/task'
require 'thor/run_tasks/install/deployment/templates'

module Thor
  module RunTask
    module Install      
      module Deploy

        def do_deployment
          deploy_tasks_and_templates if do_deploy?        
        end

        def do_deploy?
          return nil if options["deploy"] == false # don't deploy if option explicitly set to false!
          !(name =~ /^http:\/\//) && options["deploy"] || yes?("Do you wish to deploy [y/N]?")
        end

        def deploy_tasks_and_templates
          deploy_task
          deploy_templates if do_deploy_templates?              
        end
                
        def deploy_task   
          as_name = as.gsub /\.thor$/, ''
                     
          if !template_path
            say "You can set the environment variable THOR_TEMPLATE_PATH to point to a dir that acts as a template repository for all thor tasks."      
            say "This template repository must reside outside the thor root repository: #{thor_root}"                  
          end
    
          # deploy template to .thor_tasks/[name] by default
          # allow to deploy to alternative location!
          create_deploy_target_dir name

          lib_dir? ? deploy_first_thor_file : say "Deployment expect a lib directory that contains one or more .thor files and supporting files"
        end
      end
    end    
  end
end
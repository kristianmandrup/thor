require 'thor/run_tasks/install/deployment/task_util'

module Thor
  module RunTask
    module Install
      module DeployTask
        include Thor::TaskUtil

        def deploy_task              
          if !template_path
            say "You can set the environment variable THOR_TEMPLATE_PATH to point to a dir that acts as a template repository for all thor tasks."      
            say "This template repository must reside outside the thor root repository: #{thor_root}"                  
          end
    
          # deploy template to .thor_tasks/[name] by default
          # allow deployment to alternative location!
          create_deploy_target_dir

          # if there is a lib dir, deploy the first thor file found there
          # otherwise notify user that this is the convention
          lib_dir? ? deploy_first_thor_file : say "Deployment expect a lib directory that contains one or more .thor files and supporting files"
        end

    end
  end
end


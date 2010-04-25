module Thor
  module TaskUtil
    def create_deploy_target_dir
      FileUtils.mkdir_p thor_task_deploy_path if !File.directory?(thor_task_deploy_path)
    end

    # Design Note: Perhaps better to first filter out any extranous thor files from files being deployed, then point to the only thor file deployed!

    # get the first thor file from lib and deploy it. Otherwise notify 
    def deploy_first_thor_file
      first_thor_file ? deploy_lib : say "Deployment expects one or more .thor files to reside in the lib directory"
    end

    # Not sure about this. What is correct action if multiple thor files are found!?
    def first_thor_file
      filelist = FileList['lib/*.thor']
      @first_thor_file ||= filelist.first
    end

    def thor_task_deploy_path 
      File.join(thor_deploy_path, as_name)      
    end

    # deploy the complete lib directory to ensure any dependencies of thor file is met
    def deploy_lib
      FileUtils.cp_r('lib/.', target_dir)               
      thor_yaml[as][:location] = filelist_deployed.first # set location of thor file for configuration in thor repo 
    end

    # yikes! should we deploy multiple thor files!?
    def filelist_deployed
      filelist_deployed = FileList["*.thor"]
      filelist_deployed.reject!{|f| !File.exist?(f)}
      @filelist_deployed ||= filelist_deployed.uniq!
    end

    def thor_deploy_path 
      options["deploy-path"] || thor_default_deploy_path           
    end

    def thor_default_deploy_path
      ENV['THOR_DEPLOY_PATH'] || File.join(ENV['HOME'], '.thor_deploy')
    end
  end
end
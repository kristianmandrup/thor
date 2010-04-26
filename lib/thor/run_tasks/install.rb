# Contains runner tasks for install, installed and uninstall 
require 'thor/run_tasks/install/deploy'
require 'thor/run_tasks/install/finder'
require 'thor/run_tasks/install/repo'
require 'thor/run_tasks/install/util'

module Thor
  module RunTask
    module Install
      # first find the tasks to install
      include Finder                   
      # optionally deploy the task
      include Deploy
      # update the repository to point to the task (the original or the deployed task)
      include Repository
      include Util

      # List installed thor modules and tasks
      desc "installed", "List the installed Thor modules and tasks"
      method_options :internal => :boolean
      def installed
        initialize_thorfiles(nil, true)
        display_klasses(true, options["internal"])
      end

      # install named thor tasks or all tasks found 
      desc "install [NAMES]", "Install one or more named Thor files or all Thor files found into your system tasks"
      method_options :as => :string, :force => :boolean, , :verbose => :boolean
      def install(names=nil)
        initialize_thorfiles
        find_thor_tasks(names).each{|task| task.install!} 
      end

      # update installed thor file
      desc "update NAME", "Update a Thor file from its original location"
      def update(name)
        raise Error, "Can't find module '#{name}' in #{thor_root}" if !thor_yaml[name] || !thor_yaml[name][:location]

        say "Updating '#{name}' from #{thor_yaml[name][:location]}"

        old_filename = thor_yaml[name][:filename]
        self.options = self.options.merge("as" => name)
        filename     = install(thor_yaml[name][:location])

        unless filename == old_filename
          File.delete(File.join(thor_root, old_filename))
        end
      end

      # uninstall an installed thor task    
      desc "uninstall NAME", "Uninstall a named Thor module"
      def uninstall(name)
        raise Error, "Can't find module '#{name}' in #{thor_root}" unless thor_yaml[name]
        say "Uninstalling #{name}."

        file = File.join(thor_root, "#{thor_yaml[name][:filename]}")
        FileUtils.rm_rf(file)

        dir = File.join(thor_root, name)
        FileUtils.rm_rf(dir) if File.directory?(dir)

        if ENV['THOR_TEMPLATE_PATH']
          template_dir = File.join(ENV['THOR_TEMPLATE_PATH'], name)
          FileUtils.rm_rf(template_dir) if File.directory?(template_dir)      
        end

        thor_yaml.delete(name)
        save_yaml(thor_yaml)

        puts "Done."
      end
    end
  end
end
require 'thor'
require 'thor/group'
require 'thor/core_ext/file_binary_read'

require 'rake'
require 'fileutils'
require 'open-uri'
require 'yaml'
require 'digest/md5'
require 'pathname'

require 'thor/run_tasks/info' 
require 'thor/run_tasks/install' 

class Thor::Runner < Thor #:nodoc:
  map "-T" => :list, "-i" => :install, "-u" => :update, "-v" => :version

  attr_accessor :as, :as_name

  include RunTask::Install
  include RunTask::Info

  # If a task is not found on Thor::Runner, method missing is invoked and
  # Thor::Runner is then responsable for finding the task in all classes.
  #
  def method_missing(meth, *args)
    meth = meth.to_s
    initialize_thorfiles(meth)
    klass, task = Thor::Util.find_class_and_task_by_namespace(meth)
    args.unshift(task) if task
    klass.start(args, :shell => self.shell)
  end

  private

    def self.banner(task)
      "thor " + task.formatted_usage(self, false)
    end

    def thor_root
      Thor::Util.thor_root
    end

    def thor_yaml
      @thor_yaml ||= begin
        yaml_file = File.join(thor_root, "thor.yml")
        yaml = YAML.load_file(yaml_file) if File.exists?(yaml_file)
        yaml || {}
      end
    end

    def self.exit_on_failure?
      true
    end

    include Thor::RunnerHelper:ThorFiles

end
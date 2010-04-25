require 'thor/run_tasks/list/helper'
require 'thor/run_tasks/list/thor_files'

module Thor
  module RunTask
    module Info
      include List
      include ThorFiles
      
      # Show help about how to use thor            
      # Override Thor#help so it can give information about any class and any method.
      def help(meth=nil)
        if meth && !self.respond_to?(meth)
          initialize_thorfiles(meth)
          klass, task = Thor::Util.find_class_and_task_by_namespace(meth)
          klass.start(["-h", task].compact, :shell => self.shell)
        else
          super
        end
      end

      # Show version of thor
      desc "version", "Show Thor version"
      def version
        require 'thor/version'
        say "Thor #{Thor::VERSION}, repository: #{thor_root}"
      end

      # list all available thor tasks from the current location
      desc "list [SEARCH]", "List the available thor tasks (--substring means .*SEARCH)"
      method_options :substring => :boolean, :group => :string, :all => :boolean
      def list(search="")
        initialize_thorfiles

        search = ".*#{search}" if options["substring"]
        search = /^#{search}.*/i
        group  = options[:group] || "standard"

        klasses = Thor::Base.subclasses.select do |k|
          (options[:all] || k.group == group) && k.namespace =~ search
        end

        display_klasses(false, false, klasses)
      end
      
    end
  end
end                 

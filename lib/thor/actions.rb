require 'fileutils'
require 'thor/core_ext/file_binary_read'

Dir[File.join(File.dirname(__FILE__), "actions", "*.rb")].each do |action|
  require action
end

class Thor
  module Actions
    attr_accessor :behavior

    # easy to enable/disable action modules! use autoload?
    include Core
    include File
    include FileManipulation
    include Code
    include CodeManipulation
    include Directory
    include Templates

    def self.included(base) #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      # Hold source paths for one Thor instance. source_paths_for_search is the
      # method responsible to gather source_paths from this current class,
      # inherited paths and the source root.
      #
      def source_paths
        @source_paths ||= []
      end

      # Returns the source paths in the following order:
      #
      #   1) This class source paths
      #   2) Source root
      #   3) Parents source paths
      #
      def source_paths_for_search
        paths = []
        paths += self.source_paths
        paths << self.source_root if self.respond_to?(:source_root)
        paths += from_superclass(:source_paths, [])
        paths
      end

      # Add runtime options that help actions execution.
      #
      def add_runtime_options!
        class_option :force, :type => :boolean, :aliases => "-f", :group => :runtime,
                             :desc => "Overwrite files that already exist"

        class_option :pretend, :type => :boolean, :aliases => "-p", :group => :runtime,
                               :desc => "Run but do not make any changes"

        class_option :quiet, :type => :boolean, :aliases => "-q", :group => :runtime,
                             :desc => "Supress status output"

        class_option :skip, :type => :boolean, :aliases => "-s", :group => :runtime,
                            :desc => "Skip files that already exist"
      end
    end

    # Extends initializer to add more configuration options.
    #
    # ==== Configuration
    # behavior<Symbol>:: The actions default behavior. Can be :invoke or :revoke.
    #                    It also accepts :force, :skip and :pretend to set the behavior
    #                    and the respective option.
    #
    # destination_root<String>:: The root directory needed for some actions.
    #
    def initialize(args=[], options={}, config={})
      self.behavior = case config[:behavior].to_s
        when "force", "skip"
          _cleanup_options_and_set(options, config[:behavior])
          :invoke
        when "revoke"
          :revoke
        else
          :invoke
      end

      super
      self.destination_root = config[:destination_root]
    end



  end
end

module Thor
  module RunnerTask
    module Info
      module ThorFiles 
        # Load the thorfiles. If relevant_to is supplied, looks for specific files
        # in the thor_root instead of loading them all.
        #
        # By default, it also traverses the current path until find Thor files, as
        # described in thorfiles. This look up can be skipped by suppliying
        # skip_lookup true.
        #
        def initialize_thorfiles(relevant_to=nil, skip_lookup=false)
          thorfiles(relevant_to, skip_lookup).each do |f|
            Thor::Util.load_thorfile(f) unless Thor::Base.subclass_files.keys.include?(File.expand_path(f))
          end
        end

        # Finds Thorfiles by traversing from your current directory down to the root
        # directory of your system. If at any time we find a Thor file, we stop.
        #
        # We also ensure that system-wide Thorfiles are loaded first, so local
        # Thorfiles can override them.
        #
        # ==== Example
        #
        # If we start at /Users/wycats/dev/thor ...
        #
        # 1. /Users/wycats/dev/thor
        # 2. /Users/wycats/dev
        # 3. /Users/wycats <-- we find a Thorfile here, so we stop
        #
        # Suppose we start at c:\Documents and Settings\james\dev\thor ...
        #
        # 1. c:\Documents and Settings\james\dev\thor
        # 2. c:\Documents and Settings\james\dev
        # 3. c:\Documents and Settings\james
        # 4. c:\Documents and Settings
        # 5. c:\ <-- no Thorfiles found!
        #
        def thorfiles(relevant_to=nil, skip_lookup=false)
          thorfiles = []

          unless skip_lookup
            Pathname.pwd.ascend do |path|
              thorfiles = Thor::Util.globs_for(path).map { |g| Dir[g] }.flatten
              break unless thorfiles.empty?
            end
          end

          files  = (relevant_to ? thorfiles_relevant_to(relevant_to) : Thor::Util.thor_root_glob)
          files += thorfiles
          files -= ["#{thor_root}/thor.yml"]

          files.map! do |file|
            File.directory?(file) ? File.join(file, "main.thor") : file
          end
        end

        # Load thorfiles relevant to the given method. If you provide "foo:bar" it
        # will load all thor files in the thor.yaml that has "foo" e "foo:bar"
        # namespaces registered.
        #
        def thorfiles_relevant_to(meth)
          lookup = [ meth, meth.split(":")[0...-1].join(":") ]

          files = thor_yaml.select do |k, v|
            v[:namespaces] && !(v[:namespaces] & lookup).empty?
          end

          files.map { |k, v| File.join(thor_root, "#{v[:filename]}") }
        end
      end
    end
  end
end

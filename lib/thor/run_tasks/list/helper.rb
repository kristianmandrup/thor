module Thor
  module RunTask
    module List

      # Display information about the given klasses. If with_module is given,
      # it shows a table with information extracted from the yaml file.
      #
      def display_klasses(with_modules=false, show_internal=false, klasses=Thor::Base.subclasses)
        klasses -= [Thor, Thor::Runner, Thor::Group] unless show_internal

        raise Error, "No Thor tasks available" if klasses.empty?
        show_modules if with_modules && !thor_yaml.empty?

        # Remove subclasses
        klasses.dup.each do |klass|
          klasses -= Thor::Util.thor_classes_in(klass)
        end

        # put printable tasks for namespaced group classes in their own shortened namespace (using module as namespace and thus removing class part)
        ns_groups.each do |k|
          ns = shorten_ns(k.namespace)
          list[ns] += k.printable_tasks(false)
        end

        # put printable tasks for regular namespaced classes in their own namespace
        ns_classes.each { |k| list[k.namespace] += k.printable_tasks(false) }

        # put root classes in root namespace
        root_klasses.map! { |k| k.printable_tasks(false).first }
        
        order_list.each { |n, tasks| display_tasks(n, tasks) unless tasks.empty? }
      end

      def order_list
        list["root"] = root_klasses
        # Order namespaces with default coming first
        list = list.sort{ |a,b| a[0].sub(/^default/, '') <=> b[0].sub(/^default/, '') }
      end

      def list
        @list ||= Hash.new { |h,k| h[k] = [] }
      end

      # Get classes which are not root classes and not namespaced group classes - thus regular namespaced classes
      def ns_classes
        @ns_classes ||= (klasses - root_klasses - ns_groups)
      end
      
      # Get namespaced group classes, group classes except for root classes
      def ns_groups
        @ns_groups ||= (groups - root_klasses)
      end

        # Get root classes from group classes, those without a ':' in their full class name (namespace)
      def root_klasses
        @root_klasses ||= groups.select do |k|
          !(/:/ =~ k.namespace)
        end
      end

      # Get group classes based on inheritace from Thor::Group
      def groups
        @groups ||= klasses.select { |k| k.ancestors.include?(Thor::Group) }
      end

      def display_tasks(namespace, list) #:nodoc:
        list.sort!{ |a,b| a[0] <=> b[0] }

        say shell.set_color(namespace, :blue, true)
        say "-" * namespace.size

        print_table(list, :truncate => true)
        say
      end

      def shorten_ns(namespace)
        ns = namespace.split(':')
        ns.pop
        ns.join(':')
      end

      def show_modules #:nodoc:
        info  = []
        labels = ["Modules", "Namespaces"]

        info << labels
        info << [ "-" * labels[0].size, "-" * labels[1].size ]

        thor_yaml.each do |name, hash|
          info << [ name, hash[:namespaces].join(", ") ]
        end

        print_table info
        say ""
      end
    end
  end
end
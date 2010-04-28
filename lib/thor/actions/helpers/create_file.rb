class Thor
  module Action
    module Helpers
      # AddFile is a subset of Template, which instead of rendering a file with
      # ERB, it gets the content from the user.
      #
      class CreateFile < EmptyDirectory #:nodoc:
        attr_reader :data

        def initialize(base, destination, data, config={})
          @data = data
          super(base, destination, config)
        end

        # Checks if the content of the file at the destination is identical to the rendered result.
        #
        # ==== Returns
        # Boolean:: true if it is identical, false otherwise.
        #
        def identical?
          exists? && File.binread(destination) == render
        end

        # Holds the content to be added to the file.
        #
        def render
          @render ||= if data.is_a?(Proc)
            data.call
          else
            data
          end
        end

        def invoke!
          invoke_with_conflict_check do
            FileUtils.mkdir_p(File.dirname(destination))
            File.open(destination, 'wb') { |f| f.write render }
          end
          given_destination
        end

        protected

          # Now on conflict we check if the file is identical or not.
          #
          def on_conflict_behavior(&block)
            if identical?
              say_status :identical, :blue
            else
              options = base.options.merge(config)
              force_or_skip_or_conflict(options[:force], options[:skip], &block)
            end
          end

          # If force is true, run the action, otherwise check if it's not being
          # skipped. If both are false, show the file_collision menu, if the menu
          # returns true, force it, otherwise skip.
          #
          def force_or_skip_or_conflict(force, skip, &block)
            if force
              say_status :force, :yellow
              block.call unless pretend?
            elsif skip
              say_status :skip, :yellow
            else
              say_status :conflict, :red
              force_or_skip_or_conflict(force_on_collision?, true, &block)
            end
          end

          # Shows the file collision menu to the user and gets the result.
          #
          def force_on_collision?
            base.shell.file_collision(destination){ render }
          end

      end
    end
  end
end
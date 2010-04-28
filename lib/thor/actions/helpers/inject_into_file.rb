require 'thor/actions/helpers/empty_directory'

class Thor
  module Action
    module Helpers

      class InjectIntoFile < EmptyDirectory #:nodoc:
        attr_reader :replacement, :flag, :behavior

        def initialize(base, destination, data, config)
          super(base, destination, { :verbose => true }.merge(config))

          @behavior, @flag = if @config.key?(:after)
            [:after, @config.delete(:after)]
          else
            [:before, @config.delete(:before)]
          end

          @replacement = data.is_a?(Proc) ? data.call : data
          @flag = Regexp.escape(@flag) unless @flag.is_a?(Regexp)
        end

        def invoke!
          say_status :invoke

          content = if @behavior == :after
            '\0' + replacement
          else
            replacement + '\0'
          end

          replace!(/#{flag}/, content, config[:force])
        end

        def revoke!
          say_status :revoke

          regexp = if @behavior == :after
            content = '\1\2'
            /(#{flag})(.*)(#{Regexp.escape(replacement)})/m
          else
            content = '\2\3'
            /(#{Regexp.escape(replacement)})(.*)(#{flag})/m
          end

          replace!(regexp, content, true)
        end

        protected

          def say_status(behavior)
            status = if flag == /\A/
              behavior == :invoke ? :prepend : :unprepend
            elsif flag == /\z/
              behavior == :invoke ? :append : :unappend
            else
              behavior == :invoke ? :inject : :deinject
            end

            super(status, config[:verbose])
          end

          # Adds the content to the file.
          #
          def replace!(regexp, string, force)
            unless base.options[:pretend]
              content = File.binread(destination)
              if force || !content.include?(replacement)
                content.gsub!(regexp, string)
                File.open(destination, 'wb') { |file| file.write(content) }
              end
            end
          end
      end
    end
  end
end
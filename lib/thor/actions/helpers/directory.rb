require 'thor/actions/helpers/empty_directory'

class Thor
  module Action
    module Helpers

      class Directory < EmptyDirectory #:nodoc:
        attr_reader :source

        def initialize(base, source, destination=nil, config={}, &block)
          @source = File.expand_path(base.find_in_source_paths(source.to_s))
          @block  = block
          super(base, destination, { :recursive => true }.merge(config))
        end

        def invoke!
          base.empty_directory given_destination, config
          execute!
        end

        def revoke!
          execute!
        end

        protected

          def execute!
            lookup = config[:recursive] ? File.join(source, '**') : source
            lookup = File.join(lookup, '{*,.[a-z]*}')

            Dir[lookup].each do |file_source|
              next if File.directory?(file_source)
              file_destination = File.join(given_destination, file_source.gsub(source, '.'))
              file_destination.gsub!('/./', '/')

              case file_source
                when /\.empty_directory$/
                  dirname = File.dirname(file_destination).gsub(/\/\.$/, '')
                  next if dirname == given_destination
                  base.empty_directory(dirname, config)
                when /\.tt$/
                  destination = base.template(file_source, file_destination[0..-4], config, &@block)
                else
                  destination = base.copy_file(file_source, file_destination, config, &@block)
              end
            end
          end

      end
    end
  end
end
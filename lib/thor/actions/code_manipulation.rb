require 'thor/actions/helpers/inject_into_file'

class Thor
  module Actions
    module CodeManipulation
      # Injects text right after the class definition. Since it depends on
      # inject_into_file, it's reversible.
      #
      # ==== Parameters
      # path<String>:: path of the file to be changed
      # klass<String|Class>:: the class to be manipulated
      # data<String>:: the data to append to the class, can be also given as a block.
      # config<Hash>:: give :verbose => false to not log the status.
      #
      # ==== Examples
      #
      #   inject_into_class "app/controllers/application_controller.rb", "  filter_parameter :password\n"
      #
      #   inject_into_class "app/controllers/application_controller.rb", ApplicationController do
      #     "  filter_parameter :password\n"
      #   end
      #
      def inject_into_class(path, klass, *args, &block)
        config = parse_args(args)
        config.merge!(:after => /class #{klass}\n|class #{klass} .*\n/) 
        inject_into_file(path, *(args << config), &block)
      end
    end
  end
end
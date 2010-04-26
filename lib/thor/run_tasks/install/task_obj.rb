module Thor
  module TaskObj
    attr_accessor :name, :as_name, :contents, :base, :location

    def install!
      display_task if !options[:force]
      configure!
      deploy! if options[:deploy]
      update_repo!
    end
    
    def contents
      @contents ||= open(name).read
    end
  end
end
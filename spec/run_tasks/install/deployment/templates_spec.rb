require File.expand_path(File.dirname(__FILE__) + "../../../spec_helper")
require 'thor/runner'

# A typical thor task project layout
# 
# rspec-project
#   - _signatures
#     - APP.RUBY.TASK.THOR.signature
#   - lib
#     - configure.thor
#     - run.thor
#     - helpers
#        rspec_helper.rb
#     - templates
#       - shared
#         - README.template
#       - configure
#         - rspec_config.template
#       - run
#         - rspec_run.template      

# The templates are deployed to a common repository with this layout 

# .thor-templates
#  - rspec (project)
#    - shared
#    - configure (task)
#    - run (task)  
#  - cucumber
#    - shared
#    - test (task)
#    - rails (task)

# when a task is run the templates_ref starts by pointing the templates folder as given by project_name/task_name
# The templates_ref can then be changed as needed, fx
# templates_ref :shared do
#   template README.template
# end  
# templates_ref :project => :cucumber (if no task option given, by default uses 'shared') if no matching folder found, raises error!

describe Thor::Runner do
  it "should deploy templates with deployment of task" do
    # fixture with two thor files in both project root and in /lib. One thor file is found in both locations
    fail "test not yet implemented"      
  end
end
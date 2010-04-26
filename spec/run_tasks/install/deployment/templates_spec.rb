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

# Templates can also be deployed to a github repository, fx http://github.com/kristianmandrup/rspec-project
# The convention here is to have a /templates directory in the root, allowing for other rootfiles such as README etc not to be mixed with the template files

# $ thor install --remote-template-path http://github.com/kristianmandrup/rspec-project/tree/alternative    
# $ thor install --remote-template-repo http://github.com/kristianmandrup/thor-templates    

# Note it should be possible to provide a default for --remote-template-repo in an environment variable or sth.

# 
# http://github.com/kristianmandrup/rspec-project/ (master branch)
# http://github.com/kristianmandrup/rspec-project/tree/alternative (alternative branch)

#     - templates
#       - shared
#         - README.template
#       - configure
#         - rspec_config.template
#       - run
#         - rspec_run.template      

# You could also have a repository set up to be the full templates repo for multiple thor task projects
# http://github.com/kristianmandrup/thor-templates/ (master branch)
#  - rspec (project)
#    - shared
#    - configure (task)
#      - rspec_config.template
#    - run (task)  
#      - rspec_run.template      
#  - cucumber
#    - shared
#    - test (task)
#    - rails (task)

# The task can then use the methods remote_template_path and remote_template_repo, something like this
# remote_template_path :github => {:user => 'kmandrup', :name => 'rspec-project', :branch => :alternative}
# remote_template_repo :github => {:user => 'kmandrup', :name => 'thor-templates'}
# 
# These are used from within the task (defaults). If you want to run a task and have it use a set of templates at a different location, you can do it like this
#   
# $ thor rspec:run --remote-template-path http://github.com/kristianmandrup/rspec-project/tree/alternative    
# $ thor rspec:run --remote-template-repo http://github.com/kristianmandrup/thor-templates    

describe Thor::Runner do
  it "should deploy templates with deployment of task" do
    # fixture with two thor files in both project root and in /lib. One thor file is found in both locations
    fail "test not yet implemented"      
  end
end


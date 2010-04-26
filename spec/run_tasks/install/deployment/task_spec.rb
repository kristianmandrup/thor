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

# The thor tasks rspec and rspec_util are both in the same project called 'rspec-project'. By default, the installer can find the project information in the signature file.
# The user then has the option to override this name as part of install/deploy process (or if no signature file present)
# The tasks will each be deployed in the thor repo under a namespace, according to their internal configuration (according to fx Thor::Group, Module container or namespace)

# The tasks will both be deployed to the same thor project repo folder

# Example of thor projects repository:

# .thor-projects
# - rspec-project (tasks container project)
#   - lib
#     - rspec.thor
#     - rspec_util.thor
#     - helpers
#        rspec_helper.rb
# - github-tasks (another tasks container project)
#  - lib
#    - ...

describe Thor::Runner do
  it "should install thor file with deployment of task" do
    # fixture with two thor files in both project root and in /lib. One thor file is found in both locations
    fail "test not yet implemented"      
  end
end
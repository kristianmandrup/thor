require File.expand_path(File.dirname(__FILE__) + "../../spec_helper")
require 'thor/runner'

describe Thor::Runner do

  it "should install thor file with deployment of task" do
    # fixture with two thor files in both project root and in /lib. One thor file is found in both locations
    fail "test not yet implemented"      
  end

  it "should install thor file with the name stripped off '.thor' by default" do
    # fixture with a thor file. Check name of task using: task list NAME
    fail "test not yet implemented"      
  end


  it "should install /lib thor file with deployment of task and templates" do
    # fixture with thor file in /lib and templates in /lib/templates
    # Task is deployed to THOR_DEPLOY_PATH
    # Templates are deployed to THOR_TEMPLATE_PATH
  
    # Currently for a templates deployment, a templates repository is created for each task. 
    # It should be possible to reuse templates for multiple tasks, as this is often a use case 

    # This could be a good design for a templates deployment layout 
    # templates
    #  - rspec (project)
    #    - shared
    #    - configure (task)
    #    - run (task)  
    #  - cucumber
    #    - shared
    #    - test (task)
    #    - rails (task)

    # each project has its own template repository
    # there is a 'shared' folder containing templates used by one or more of the tasks in the project
    # each task then also has its own private folder of templates 

    # Examples of new template operations needed:

    # templates_ref :project => 'rspec', :configure
    # template operations are now relative to the template repository at rspec/configure  

    # templates_ref :shared
    # change templates reference pointer to use shared templates for rspec 
  
    # NOTE: This should also work when having the templates deployed in a VC repository, fx on github!     
  
    fail "test not yet implemented"      
  end

  it "should install /lib thor file with deployment of task and templates even when templates are in project root" do
    # fixture with thor file in /lib and templates in ROOT/templates
    fail "test not yet implemented"      
  end
end
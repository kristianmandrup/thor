require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'thor/actions'

describe Thor::Actions do
  before(:each) do
    let(:name) { 'test_task' }
  end

  def runner(options={})
    @runner ||= MyCounter.new([1], options, { :destination_root => destination_root })
  end

  def action(*args, &block)
    capture(:stdout){ runner.send(*args, &block) }
  end

  def task_file
    File.join(source_root, 'task.thor')    
  end
  
  # helpers to get path to task templates
  
  describe "#local_template_path" do
    path = local_template_path(__FILE__)
    path.must match(File.join(File.dirname(task_file), 'templates'))                
  end

  describe "#repo_template_path" do
    it "should use the default repo if none provided" do
      path = repo_template_path(task_file)                                             
      path.must match('kristianmandrup/thor_task_repo/test_task/templates')            
    end
  end

  describe "#remote_template_path" do
    it "should use the default remote repo if none provided" do
      ENV['THOR_REMOTE_TEMPLATES_PATH'] = 'github:kristianmandrup/thor_task_repo'            
      path = remote_template_path(task_file)
      path.must match('kristianmandrup/thor_task_repo/test_task/templates')      
    end

    it "should use the remote repo provided" do
      ENV['THOR_REMOTE_TEMPLATES_PATH'] = ''                  
      path = remote_template_path(task_file, :repo => 'github:kristianmandrup/thor_task_repo')
      path.must match('kristianmandrup/thor_task_repo/test_task/templates')
    end

    it "should use the remote repo provided" do               
      ENV['THOR_REMOTE_TEMPLATES_PATH'] = ''
      path = remote_template_path(task_file, :repo => 'github:kristianmandrup')
      path.must match('kristianmandrup/test_task/templates')
    end

  end              
  
end
  
require File.expand_path(File.dirname(__FILE__) + "../spec_helper")
require 'thor/runner'

describe Thor::Runner do
  describe "uninstall" do
    before(:each) do
      path = File.join(Thor::Util.thor_root, @original_yaml["random"][:filename])
      FileUtils.should_receive(:rm_rf).with(path)
    end

    it "uninstalls existing thor modules" do
      silence(:stdout) { Thor::Runner.start(["uninstall", "random"]) }
    end
  end

  describe "installed" do
    before(:each) do
      Dir.should_receive(:[]).and_return([])
    end

    it "displays the modules installed in a pretty way" do
      stdout = capture(:stdout) { Thor::Runner.start(["installed"]) }
      stdout.must =~ /random\s*amazing/
      stdout.must =~ /amazing:describe NAME\s+# say that someone is amazing/m
    end
  end

  describe "install/update" do
    before(:each) do
      FileUtils.stub!(:mkdir_p)
      FileUtils.stub!(:touch)
      $stdin.stub!(:gets).and_return("Y")

      path = File.join(Thor::Util.thor_root, Digest::MD5.hexdigest(@location + "random"))
      File.should_receive(:open).with(path, "w")
    end

    it "updates existing thor files" do
      path = File.join(Thor::Util.thor_root, @original_yaml["random"][:filename])
      File.should_receive(:delete).with(path)
      silence(:stdout) { Thor::Runner.start(["update", "random"]) }
    end

    it "installs thor files" do
      ARGV.replace ["install", @location]
      silence(:stdout) { Thor::Runner.start }
    end

    it "should install a thor file found in the root project directory" do
      # fixture with a thor file in project root only
      fail "test not yet implemented"
    end
    
    it "should install a thor file found inside the /lib directory" do
      # fixture with a thor file in /lib only
      fail "test not yet implemented"
    end

    it "should install the thor file found inside the /lib directory since it has higher precedence than thor files found elsewhere" do
      # fixture with a thor file in both project root and in /lib
      fail "test not yet implemented"
    end

    # How do we handle if a thor project has multiple thor files?
    it "should install each thor file found inside the /lib directory as a separate entry" do
      # fixture with multiple thor files in /lib
      fail "test not yet implemented"
    end

    it "should install each thor file found inside the /lib directory as a separate entry" do
      # fixture with a thor file in both project root and in /lib
      fail "test not yet implemented"
      
      # Finder should find all thor files both in project root and lib. If any duplicates found (task with same name), /lib version takes precedence!
      # for each task found, run Install
      # Install displays task description and version (why show the source code!?)
      # Install optionally starts Deployment if 
      # deploys the task and templates (if templates dir found) 
      # Repository updated with entry for task 
    end

    it "should install each thor file found inside both the project root and the /lib directory as a separate entry, applying precedence rules where lib wins" do
      # fixture with two thor files in both project root and in /lib. One thor file is found in both locations
      fail "test not yet implemented"      
    end

    it "should install thor file without deployment" do
      # fixture with two thor files in both project root and in /lib. One thor file is found in both locations
      fail "test not yet implemented"      
    end


      
  end
end
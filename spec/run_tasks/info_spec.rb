require File.expand_path(File.dirname(__FILE__) + "../spec_helper")
require 'thor/runner'

describe Thor::Runner do
  describe "#help" do
    it "shows information about Thor::Runner itself" do
      capture(:stdout){ Thor::Runner.start(["help"]) }.must =~ /List the available thor tasks/
    end

    it "shows information about a specific Thor::Runner task" do
      content = capture(:stdout){ Thor::Runner.start(["help", "list"]) }
      content.must =~ /List the available thor tasks/
      content.must_not =~ /help \[TASK\]/
    end

    it "shows information about a specific Thor class" do
      content = capture(:stdout){ Thor::Runner.start(["help", "my_script"]) }
      content.must =~ /zoo\s+# zoo around/m
    end

    it "shows information about an specific task from an specific Thor class" do
      content = capture(:stdout){ Thor::Runner.start(["help", "my_script:zoo"]) }
      content.must =~ /zoo around/
      content.must_not =~ /help \[TASK\]/
    end

    it "shows information about a specific Thor group class" do
      content = capture(:stdout){ Thor::Runner.start(["help", "my_counter"]) }
      content.must =~ /my_counter N/
    end

    it "raises error if a class/task cannot be found" do
      content = capture(:stderr){ Thor::Runner.start(["help", "unknown"]) }
      content.strip.must == 'Could not find task "unknown" in "default" namespace.'
    end
  end    
  
  describe "list" do
    it "gives a list of the available tasks" do
      ARGV.replace ["list"]
      content = capture(:stdout) { Thor::Runner.start }
      content.must =~ /amazing:describe NAME\s+# say that someone is amazing/m
    end

    it "gives a list of the available Thor::Group classes" do
      ARGV.replace ["list"]
      capture(:stdout) { Thor::Runner.start }.must =~ /my_counter N/
    end

    it "can filter a list of the available tasks by --group" do
      ARGV.replace ["list", "--group", "standard"]
      capture(:stdout) { Thor::Runner.start }.must =~ /amazing:describe NAME/
      ARGV.replace []
      capture(:stdout) { Thor::Runner.start }.must_not =~ /my_script:animal TYPE/
      ARGV.replace ["list", "--group", "script"]
      capture(:stdout) { Thor::Runner.start }.must =~ /my_script:animal TYPE/
    end

    it "can skip all filters to show all tasks using --all" do
      ARGV.replace ["list", "--all"]
      content = capture(:stdout) { Thor::Runner.start }
      content.must =~ /amazing:describe NAME/
      content.must =~ /my_script:animal TYPE/
    end

    it "doesn't list superclass tasks in the subclass" do
      ARGV.replace ["list"]
      capture(:stdout) { Thor::Runner.start }.must_not =~ /amazing:help/
    end

    it "presents tasks in the default namespace with an empty namespace" do
      ARGV.replace ["list"]
      capture(:stdout) { Thor::Runner.start }.must =~ /^thor :cow\s+# prints 'moo'/m
    end

    it "runs tasks with an empty namespace from the default namespace" do
      ARGV.replace [":task_conflict"]
      capture(:stdout) { Thor::Runner.start }.must == "task\n"
    end

    it "runs groups even when there is a task with the same name" do
      ARGV.replace ["task_conflict"]
      capture(:stdout) { Thor::Runner.start }.must == "group\n"
    end

    it "runs tasks with no colon in the default namespace" do
      ARGV.replace ["cow"]
      capture(:stdout) { Thor::Runner.start }.must == "moo\n"
    end
  end  
end
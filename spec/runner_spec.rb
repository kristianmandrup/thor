require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require 'thor/runner'

describe Thor::Runner do
  describe "#start" do
    it "invokes a task from Thor::Runner" do
      ARGV.replace ["list"]
      capture(:stdout){ Thor::Runner.start }.must =~ /my_counter N/
    end

    it "invokes a task from a specific Thor class" do
      ARGV.replace ["my_script:zoo"]
      Thor::Runner.start.must be_true
    end

    it "invokes the default task from a specific Thor class if none is specified" do
      ARGV.replace ["my_script"]
      Thor::Runner.start.must == "default task"
    end

    it "forwads arguments to the invoked task" do
      ARGV.replace ["my_script:animal", "horse"]
      Thor::Runner.start.must == ["horse"]
    end

    it "invokes tasks through shortcuts" do
      ARGV.replace ["my_script", "-T", "horse"]
      Thor::Runner.start.must == ["horse"]
    end

    it "invokes a Thor::Group" do
      ARGV.replace ["my_counter", "1", "2", "--third", "3"]
      Thor::Runner.start.must == [1, 2, 3]
    end

    it "raises an error if class/task can't be found" do
      ARGV.replace ["unknown"]
      content = capture(:stderr){ Thor::Runner.start }
      content.strip.must == 'Could not find task "unknown" in "default" namespace.'
    end

    it "does not swallow NoMethodErrors that occur inside the called method" do
      ARGV.replace ["my_script:call_unexistent_method"]
      lambda { Thor::Runner.start }.must raise_error(NoMethodError)
    end

    it "does not swallow Thor::Group InvocationError" do
      ARGV.replace ["whiny_generator"]
      lambda { Thor::Runner.start }.must raise_error(ArgumentError, /Are you sure it has arity equals to 0\?/)
    end

    it "does not swallow Thor InvocationError" do
      ARGV.replace ["my_script:animal"]
      content = capture(:stderr) { Thor::Runner.start }
      content.strip.must == '"animal" was called incorrectly. Call as "my_script:animal TYPE".'
    end
  end

  describe "tasks" do
    before(:each) do
      @location = "#{File.dirname(__FILE__)}/fixtures/task.thor"
      @original_yaml = {
        "random" => {
          :location  => @location,
          :filename  => "4a33b894ffce85d7b412fc1b36f88fe0",
          :namespaces => ["amazing"]
        }
      }

      root_file = File.join(Thor::Util.thor_root, "thor.yml")

      # Stub load and save to avoid thor.yaml from being overwritten
      YAML.stub!(:load_file).and_return(@original_yaml)
      File.stub!(:exists?).with(root_file).and_return(true)
      File.stub!(:open).with(root_file, "w")
    end
  end
end

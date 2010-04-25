module Thor
  module RunTask
    module Install
      module Repository
        def update_repo!
          save_yaml(thor_yaml)

          destination = File.join(thor_root, thor_yaml[as][:filename])

          if package == :file
            File.open(destination, "w") { |f| f.puts contents }
          else
            FileUtils.cp_r(name, destination)
          end

          thor_yaml[as][:filename] # Indicate success
        end

        # Save the yaml file. If none exists in thor root, creates one.
        #
        def save_yaml(yaml)
          yaml_file = File.join(thor_root, "thor.yml")

          unless File.exists?(yaml_file)
            FileUtils.mkdir_p(thor_root)
            yaml_file = File.join(thor_root, "thor.yml")
            FileUtils.touch(yaml_file)
          end

          File.open(yaml_file, "w") { |f| f.puts yaml.to_yaml }
        end
      end
    end
  end
end

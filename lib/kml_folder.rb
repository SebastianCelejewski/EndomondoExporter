module EndomondoExporter
	class KmlFolder
		attr_accessor :name
		attr_accessor :subfolders
		attr_accessor :workouts

		def initialize(name)
			@name = name
			@subfolders = Array.new
			@workouts = Array.new
		end

		def get_subfolder(subfolder_name)
			subfolder = @subfolders.find { |subfolder| subfolder.name == subfolder_name}
			if !subfolder
				subfolder = KmlFolder.new (subfolder_name)
				@subfolders.push subfolder
			end
			subfolder
		end

		def add_workout(workout)
			@workouts.push workout
		end
	end
end
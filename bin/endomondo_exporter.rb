require 'yaml'
require './lib/endomondo_reader'
require './lib/kml_writer'

module EndomondoExporter

	$data_folder = "./data"
	$output_folder = "./output"
	
	unless ARGV.length == 3 
		puts "Usage: ruby endomondo_exporter.rb username password workouts\n"
		puts "username - Endomondo user name\n"
		puts "password - Endomondo password\n"
		puts "workouts - number of workouts to download, starting from the most recent one (e.g. 100)\n"
		exit
	end

	login = ARGV[0]
	password = ARGV[1]
	number_of_workouts = ARGV[2]

	workouts_file_name = "#{$data_folder}/workouts.data"
	workout_file_pattern = "#{$data_folder}/workout-%s.data"
	output_file_name = "#{$output_folder}/workouts.kml"

	Dir.mkdir($data_folder) if !Dir.exist?($data_folder)
	Dir.mkdir($output_folder) if !Dir.exist?($output_folder)

	writer = KmlWriter.new
	reader = EndomondoReader.new
	reader.login(login, password)

	if File.file?(workouts_file_name)
		puts "Loading workouts from file #{workouts_file_name}"
		workouts = YAML.load(File.read(workouts_file_name))
		puts "Loading recent workouts from server"
		workoutsFromServer = reader.get_workouts_list(number_of_workouts)
		puts "Merging workouts"
		workouts = workouts | workoutsFromServer
		workouts.sort! { |a, b| b.id <=> a.id }
		puts "Saving merged workouts to #{workouts_file_name}"
		File.open(workouts_file_name, 'w') { |f| f.write(YAML.dump(workouts))}
	else
		puts "Loading initial workouts list from server"
		workouts = reader.get_workouts_list(number_of_workouts)	
		puts "Saving initial workouts list to #{workouts_file_name}"
		File.open(workouts_file_name, 'w') { |f| f.write(YAML.dump(workouts))}
	end

	puts "Loaded #{workouts.length} workouts."

	workouts.each do |workout|
		workout_file_name = workout_file_pattern % workout.id
		if File.file?(workout_file_name)
			puts "Loading workout #{workout.id} from file #{workout_file_name}"
			points = YAML.load(File.read(workout_file_name))
		else
			puts "Loading workout #{workout.id} from server"
			points = reader.get_workout_data(workout.id)
			File.open(workout_file_name, 'w') { |f| f.write(YAML.dump(points))}
		end
		workout.points = points
	end

	puts "Generating KML file."

	kml = writer.generate_kml(workouts)
	File.write(output_file_name, kml)

	puts "Done."
end
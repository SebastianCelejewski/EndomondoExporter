require 'yaml'
require './lib/endomondo_reader'
require './lib/kml_writer'

module EndomondoExporter

	unless ARGV.length == 6
		puts "Usage: ruby endomondo_exporter.rb user_label endomondo_login endomondo_password data_dir target_dir number_of_workouts\n"
		puts "user_label - custom name used in export\n"
		puts "endomondo_login - Endomondo user name\n"
		puts "endomondo_password - Endomondo password\n"
		puts "data_dir - path to a directory with cached data\n"
		puts "target_dir - path to a directory where exported file will be placed\n"
		puts "workouts - number of workouts to download from Endomondo server, starting from the most recent one (e.g. 100)\n"
		exit
	end

	label = ARGV[0]
	login = ARGV[1]
	password = ARGV[2]
	$data_folder = ARGV[3]
	$output_folder = ARGV[4]
	number_of_workouts = ARGV[5]

	workouts_file_name = "#{$data_folder}/workouts.data"
	workout_file_pattern = "#{$data_folder}/workout-%s.data"
	
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

	workouts.each_with_index do |workout, idx|
		workout_file_name = workout_file_pattern % workout.id
		if File.file?(workout_file_name)
			puts "Loading workout #{workout.id} from file #{workout_file_name} (#{idx} of #{workouts.length})"
			points = YAML.load(File.read(workout_file_name))
		else
			puts "Loading workout #{workout.id} from server (#{idx} of #{workouts.length})"
			points = reader.get_workout_data(workout.id)
			File.open(workout_file_name, 'w') { |f| f.write(YAML.dump(points))}
		end
		workout.points = points
	end

	puts "Splitting workouts into packages for each year"
	workouts_per_year = Hash.new {|h,k| h[k] = []}
	workouts.each { |x| workouts_per_year[x.date[0..3]] << x}

	puts "Generating KML files."
	workouts_per_year.keys.each do |year|
		workouts = workouts_per_year[year]
		kml = writer.generate_kml(label, year, workouts)
		output_file_name = "#{$output_folder}/#{label}-workouts-#{year}.kml"
		File.write(output_file_name, kml)
	end

	puts "Done."
end
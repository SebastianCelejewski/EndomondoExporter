require ('./lib/kml_folder')

module EndomondoExporter
	class KmlWriter
		def generate_kml(workouts)

			root_folder = generate_folder_structure(workouts)

			kml = KMLFile.new

			redLineStyle = KML::LineStyle.new
			redLineStyle.width = 2
			redLineStyle.color = "c00000ff";

			blueLineStyle = KML::LineStyle.new
			blueLineStyle.width = 2
			blueLineStyle.color = "c0ff4000";

			yellowLineStyle = KML::LineStyle.new
			yellowLineStyle.width = 2
			yellowLineStyle.color = "c0000000";

			redStyle = KML::Style.new(:id => "red", :line_style => redLineStyle)
			blueStyle = KML::Style.new(:id => "blue", :line_style => blueLineStyle)
			yellowStyle = KML::Style.new(:id => "yellow", :line_style => yellowLineStyle)

			styles = Array.new
			styles.push redStyle
			styles.push blueStyle
			styles.push yellowStyle

			folder = KML::Document.new(:name => "Endomondo Automatic Export", :styles => styles)

			root_folder.subfolders.reverse!
			root_folder.subfolders.each do |year|

				year_folder = KML::Folder.new(:name => year.name)
				folder.features << year_folder

				year.subfolders.reverse!
				year.subfolders.each do |month|

					month_folder = KML::Folder.new(:name => month.name)
					year_folder.features << month_folder

					month.subfolders.reverse!
					month.subfolders.each do |day|
						day_folder = KML::Document.new(:name => day.name, :styles => styles)
						month_folder.features << day_folder

						workout_number = 1
						day.workouts.reverse!
						day.workouts.each do |workout|
							workout_name = day_folder.name+"_%03d"%workout_number
							workout_number = workout_number.next
							puts "Exporting workout #{workout_name} to folder #{year_folder.name}/#{month_folder.name}/#{day_folder.name}"
							coordinates = workout.points.map {|point| "#{point.lon},#{point.lat}"}.join(" ")
							if (workout.sport == 1) 
								style = "#red"
							elsif (workout.sport == 2) 
								style = "#red"
							elsif (workout.sport == 16) 
								style = "#blue"
							elsif (workout.sport == 18)
								style = "#blue"
							else
								style = "#yellow"
							end
							day_folder.features << KML::Placemark.new(
								:name => "#{workout_name}",
								:style_url => style,
								:geometry => KML::LineString.new(coordinates: coordinates))
						end
					end
				end
			end

			kml.objects << folder
			kml.render
		end

		def generate_folder_structure(workouts)
			root_folder = KmlFolder.new("Root")
			workouts.each do |workout| 
				year, month, day = workout.date.split(' ')[0].split('-')

				year_folder_name = "#{year}"
				month_folder_name  = "#{year}-#{month}"
				day_folder_name = "#{year}-#{month}-#{day}"

				year_folder = root_folder.get_subfolder(year_folder_name)
				month_folder = year_folder.get_subfolder(month_folder_name)
				day_folder = month_folder.get_subfolder(day_folder_name)
				day_folder.add_workout workout
			end
			return root_folder
		end
	end
end
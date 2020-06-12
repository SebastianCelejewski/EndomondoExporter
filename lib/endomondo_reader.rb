require 'net/http'
require 'json'
require 'ruby_kml'
require './lib/endomondo_workout'

module EndomondoExporter
	class EndomondoReader

		LOGIN_REQUEST = "https://api.mobile.endomondo.com/mobile/auth?deviceId=dummy&email=%s&password=%s&country=US&action=PAIR";
		WORKOUTS_LIST_REQUEST = "https://api.mobile.endomondo.com/mobile/api/workout/list?authToken=%s&&maxResults=%s";
		WORKOUT_REQUEST = "https://api.mobile.endomondo.com/mobile/readTrack?authToken=%s&trackId=%s"

		def login(login, password)
			puts "Logging into Endomondo as #{login}."
			@authentication_token = get_authentication_token(login, password)
			puts "Authentication token: #{@authentication_token}."
		end

		def get_workouts_list(max_results)
			puts "Downloading list of workouts\n"
			uriString = WORKOUTS_LIST_REQUEST % [@authentication_token, max_results]
			uri = URI(uriString)
			response = Net::HTTP.get(uri)
			parsed_response = JSON.parse(response)
			result = parsed_response["data"].map { |workout| Workout.new(workout["id"], workout["start_time"], workout["sport"]) }
			return result
		end

		def get_workout_data(workout_id)
			puts "Downloading workout #{workout_id}... "
			result = Array.new
			uriString = WORKOUT_REQUEST % [@authentication_token, workout_id]
			uri = URI(uriString)
			response = Net::HTTP.get(uri)
			lines = response.split("\n")[2..-1];
			lines.each do |line|
				lineData = line.split(";")
				time = lineData[0]
				latitude = lineData[2]
				longtitude = lineData[3]
				point = Point.new
				point.time = time
				point.lon = longtitude
				point.lat = latitude
				result.push point
			end

			return result
		end

		def get_authentication_token(login, password)
			uriString = LOGIN_REQUEST % [login, password]
			uri = URI(uriString)
			response = Net::HTTP.get(uri)
			response = response.split("\n")[1..-1].join("\n")
			result = Hash[*response.split(/[=\n]+/)]
			authenticationToken = result["authToken"]
		end

		private :get_authentication_token
	end
end
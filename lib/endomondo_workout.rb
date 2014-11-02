module EndomondoExporter
	class Workout
		attr_accessor :id
		attr_accessor :date
		attr_accessor :sport
		attr_accessor :points

		def initialize(id, date, sport)
			@id = id
			@date = date
			@sport = sport
		end

		def eql?(other)
			id  == other.id
		end
		
		def hash
			id
		end 
	end

	class Point
		attr_accessor :time
		attr_accessor :lat
		attr_accessor :lon
	end
end
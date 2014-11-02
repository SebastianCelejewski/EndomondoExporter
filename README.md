EndomondoExporter
=================

Exports GPX tracks from Endomondo to KML file

Usage:

ruby bin/endomondo_exporter.rb UserName Password Workouts


where

UserName - Endomondo user name

Password - Endomondo password

Workouts - Number of workouts to fetch from the server


During the first run the number of workouts should be big enough to fetch all workouts stored on the server (e.g. 500).

During the consecutive runs the number of workouts should be big enough to fetch workouts added since the last run (e.g. 10).


/data directory contains cached workout data

/output directory contains generated KML file


Generated KML file contains folder structure representing years, then months, and then days.

Different types of workouts are represented by a track of a different colour.


Enjoy

Sebastian Celejewski
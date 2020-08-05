EndomondoExporter
=================

Exports GPX tracks from Endomondo to KML file

Usage:

ruby bin/endomondo_exporter.rb UserLabel EndomondoLogin EndomondoPassword DataDirectory TargetDirectory Workouts


where

UserLabel - custom user name to use in exported files

EndomondoLogin - Endomondo user name

EndomondoPassword - Endomondo password

DataDirectory - directory where user data is located

TargetDirectory - directory where output files should be placed

Workouts - Number of workouts to fetch from the server


During the first run the number of workouts should be big enough to fetch all workouts stored on the server (e.g. 500).

During the consecutive runs the number of workouts should be big enough to fetch workouts added since the last run (e.g. 10).


Generated KML file contains folder structure representing years, then months, and then days.

Different types of workouts are represented by a track of a different colour.


Enjoy

Sebastian Celejewski
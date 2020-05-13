puts "Event Manager initialized"

lines = File.readlines "event_attendees.csv"
for lines.each do |line|
	
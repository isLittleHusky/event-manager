require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "date"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_number(number)
  if number.length > 11
    "00000000000"
  elsif number.length == 11
    if number[0] == "1"
      number[1..-1]
    else
      "00000000000"
    end
  elsif number.length < 10
    "00000000000"
  elsif number.length == 10
    number
  end
end

def day_from_date(date)
  case date.wday
  when 0
    "Sunday"
  when 1
    "Monday"
  when 2
    "Tuesday"
  when 3
    "Wednesday"
  when 4
    "Thursday"
  when 5
    "Friday"
  when 6
    "Saturday"
  end
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"]
      ).officials
  rescue
    "You can find your representatives by visiting \"www.commoncause.org/take-action/find-elected-officials\""
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts(form_letter)
  end
end

puts "Event Manager initialized"

contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  number = clean_number(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])

  dt = DateTime.strptime(row[:regdate], "%m/%d/%y %k:%M")
  hour = dt.hour
  day = day_from_date(dt)

  puts "#{day} at #{hour}:00"

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
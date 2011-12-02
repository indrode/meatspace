# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

require "rubygems"
require "exifr"

def meatspace_logo
  "<h1 class=\"meatspace\">meatspace<span>v2</span></h1>"
end

def display_photo(photo, title, year)
  file = File.new(Dir.pwd + "/assets/photos/#{photo}")
  exif = EXIFR::JPEG.new(file)
  exposure = exif.exposure_time.to_s
  iso = exif.iso_speed_ratings
  date = exif.date_time
  aperture = "f#{exif.f_number.to_f}"
  
  photo_html = "<img src=\"/assets/photos/#{photo}\" alt=\"\" width=\"710\" />"
  photo_html += "<span class=\"caption\"><strong>#{title} (#{year})</strong>  &middot; #{aperture} &middot; #{exposure}s &middot; ISO #{iso}</span>"
end
require 'open-uri'
namespace :dinosaurs do
  desc "Get dinosaur descriptions from dinodax"
  task :get_data => :environment do
    Dinosaur.all.each do |dinosaur|
      data = URI.open("https://jwatoolbox.com/_next/data/7nt6E4JTmVIfBIWTqMvJA/en/dinodex/#{dinosaur.slug}.json")
      IO.copy_stream(data, Rails.root.join('tmp', 'dinosaurs', "#{dinosaur.slug}.json"))
    end
  end
end

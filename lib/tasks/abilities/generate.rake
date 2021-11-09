# read data from the downloaded dinodex files and generate a new ability file

require 'json'
require_relative './../../generators/ability/ability_generator'
namespace :abilities do
  desc "Generate full classes"
  task :generate => :environment do
    Dinosaur.all.each do |dinosaur|
      slug = dinosaur.slug
#      slug = 'refrenantem'
      puts slug
      file = File.read(Rails.root.join('data', 'dinosaurs', "#{slug}.json"))
      data =  JSON.parse(file)
      abilities = []
      abilities << data['pageProps']['detail']['moves']
      abilities << data['pageProps']['detail']['moves_swap_in']
      abilities << data['pageProps']['detail']['moves_counter']
      abilities << data['pageProps']['detail']['moves_on_escape']
      abilities.flatten!
      abilities.each do |ability|
        class_name = ability['uuid'].camelize
        Generators::Ability::AbilityGenerator.start [class_name, ability]
      end
    end
  end
end

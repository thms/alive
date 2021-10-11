# read data from the downloaded dinodex files and generate a new ability file

require 'json'
require_relative './../../../generators/ability/boss_ability_generator'
namespace :abilities do
  namespace :bosses do
    desc "Generate full classes"
    task :generate => :environment do

      Boss.all.each do |boss|
        file_name = "#{boss.slug.underscore}.json"
        puts file_name
        file = File.read(Rails.root.join('tmp', 'bosses', file_name))
        data =  JSON.parse(file)
        abilities = []
        abilities << data['pageProps']['detail']['moves']
        abilities << data['pageProps']['detail']['moves_counter']
        abilities.flatten!
        abilities.each do |ability|
          class_name = "Bosses::#{ability['uuid'].camelize}"
          Generators::Ability::BossAbilityGenerator.start [class_name, ability]
        end
      end
    end
  end
end

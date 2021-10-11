# Most minions use the same abilities that dinos use, so we copy
# when a class exists, otherwise create an empty scaffold and do it by hand

require 'json'
require_relative './../../../generators/ability/minion_ability_generator'
namespace :abilities do
  namespace :minions do
    desc "Generate full classes"
    task :generate => :environment do

      Minion.all.each do |minion|
        file_name = "#{minion.slug.underscore}.json"
        puts file_name
        file = File.read(Rails.root.join('tmp', 'minions', file_name))
        data =  JSON.parse(file)
        abilities = []
        abilities << data['pageProps']['detail']['moves']
        abilities << data['pageProps']['detail']['moves_counter']
        abilities.flatten!
        abilities.each do |ability|
        class_name = "Minions::#{ability.camelize}"
        Generators::Ability::MinionAbilityGenerator.start [class_name, ability]
        end
      end
    end
  end
end

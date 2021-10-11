require 'rails/generators'
#require 'generators/ability/ability_generator'
module Generators
  module Ability
    class MinionAbilityGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)
      argument :ability, type: :hash, default: {}


      # Most minion abilities ore copies of the dinosaur abilities, so we clone the file
      # and change the namespace if one already exists, otherwise we'll crate a an empty one
      def create_ability_file
        File.delete full_path if File.exist?(full_path)
        if File.exist?(full_dinosaur_ability_path)
          FileUtils.cp full_dinosaur_ability_path, full_path
          gsub_file full_path, "class ", "class Minions::"
        else
          template "ability.erb", full_path
        end
      end

      private

      def full_path
        "app/abilities/minions/#{file_name}.rb"
      end

      def full_dinosaur_ability_path
        "app/abilities/#{file_name}.rb"
      end

    end
  end
end

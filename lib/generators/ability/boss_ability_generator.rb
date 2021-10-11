require 'rails/generators'
require 'generators/ability/ability_generator'
module Generators
  module Ability
    class BossAbilityGenerator < AbilityGenerator
      source_root File.expand_path('templates', __dir__)
      argument :ability, type: :hash, default: {}


      def create_ability_file
        File.delete full_path if File.exist?(full_path)
        template "ability.erb", full_path
      end

      # write all the normal actions into the file
      def write_actions
        ability['effects'].each do |effect|
          self.send(effect['action'], effect)
        end
      end

      # write all the revenge actions into the file
      def write_revenge_actions
        if ability['if_revenge']
          # update cooldown, delay etc.
          insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n" do
            "    self.cooldown = #{ability['if_revenge']['cooldown']}\n"
          end
          insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n" do
            "    self.delay = #{ability['if_revenge']['delay']}\n"
          end
          ability['if_revenge']['effects'].each do |effect|
            puts effect['action']
            self.send("revenge_#{effect['action']}", effect)
          end
        end
      end

      private

      def full_path
        "app/abilities/bosses/#{file_name}.rb"
      end

    end
  end
end

require 'rails/generators'
module Generators
  module Ability
  class AbilityGenerator < Rails::Generators::NamedBase
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


    def set_is_priority
      if (ability['priority'] && ability['priority'] == 1) || (ability['trigger'] == 'swap-in')
        gsub_file full_path, "self.is_priority = false", "self.is_priority = true"
      end
    end

    def set_is_counter
      if ability['trigger'] == "counter"
        gsub_file full_path, "self.is_counter = false", "self.is_counter = true"
      end
    end

    def set_is_implemented
      gsub_file full_path, "self.is_implemented = false", "self.is_implemented = true"
    end

    private

    def full_path
      "app/abilities/#{file_name}.rb"
    end

    def attack(effect)
      gsub_file full_path, "self.damage_multiplier = 0", "self.damage_multiplier = #{effect['multiplier']}"
    end

    def run(effect)
      gsub_file full_path, "self.is_swap_out = false", "self.is_swap_out = true"
    end

    def revenge_attack(effect)
      # do nothing - check with other revnge attacks
      # attack multipler is the same for revenge rampage in both modes
    end

    def bypass_dodge(effect)
      gsub_file full_path, "self.bypass = [", "self.bypass = [:dodge, :cloak,"
    end

    def revenge_bypass_dodge(effect)
      # do nothing, already set
    end

    def bypass_armor(effect)
      gsub_file full_path, "self.bypass = [", "self.bypass = [:armor,"
    end

    def bypass_taunt(effect)
      gsub_file full_path, "self.bypass = [", "self.bypass = [:taunt,"
    end

    def revenge_bypass_armor(effect)
      # do nothing, already set to bypass armor
    end

    def damage_decrease(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
        "    defender.add_modifier(Modifiers::Distraction.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def revenge_damage_decrease(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage_revenge(defender)\n", :force => true do
        "    defender.add_modifier(Modifiers::Distraction.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def crit_decrease(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
        "    defender.add_modifier(Modifiers::ReduceCriticalChance.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def revenge_crit_decrease(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage_revenge(defender)\n", :force => true do
        "    defender.add_modifier(Modifiers::ReduceCriticalChance.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def damage_increase(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      if ['self', 'team'].include?(effect['target'])
        insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
          "    attacker.add_modifier(Modifiers::IncreaseDamage.new(#{amount}, #{turns}, #{attacks}))\n"
        end
      else
        insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
          "    defender.add_modifier(Modifiers::IncreaseDamage.new(#{amount}, #{turns}, #{attacks}))\n"
        end
      end
    end

    def revenge_damage_increase(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n", :force => true do
        "    attacker.add_modifier(Modifiers::IncreaseDamage.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def shield(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.add_modifier(Modifiers::Shields.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def revenge_shield(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n", :force => true do
        "    attacker.add_modifier(Modifiers::Shields.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def stun(effect)
      probability = (effect['probability'] * 100)
      insert_into_file full_path, :after => "result = super\n" do
        "    defender.is_stunned = rand(100) < #{probability} * (100.0 - defender.resistance(:stun)) / 100.0\n"
      end
    end

    def swap_prevent(effect)
      turns = effect['duration'][0]
      if effect['target'] == 'self'
        insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
          "    attacker.add_modifier(Modifiers::PreventSwap.new(#{turns}, 'self'))\n"
        end
      else
        insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
          "    defender.add_modifier(Modifiers::PreventSwap.new(#{turns}, 'other'))\n"
        end
      end
    end

    def revenge_swap_prevent(effect)
      swap_prevent(effect)
    end

    def speed_increase(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.add_modifier(Modifiers::IncreaseSpeed.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def heal(effect)
      amount = effect['multiplier']
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.heal(#{amount} * attacker.damage)\n"
      end
    end

    def heal_pct(effect)
      amount = effect['multiplier']
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.heal(#{amount} * attacker.health)\n"
      end
    end

    def speed_decrease(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
        "    defender.add_modifier(Modifiers::DecreaseSpeed.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def revenge_speed_decrease(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage_revenge(defender)\n", :force => true do
        "    defender.add_modifier(Modifiers::DecreaseSpeed.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def remove_speed_decrease(effect)
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.remove_speed_decrease\n"
      end
    end

    def remove_crit_decrease(effect)
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.remove_critical_chance_decrease\n"
      end
    end

    def dot(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
        "    defender.add_modifier(Modifiers::DamageOverTime.new(#{amount}, #{turns}))\n"
      end
    end

    def remove_all_neg(effect)
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.cleanse(:all)\n"
      end
    end

    def remove_all_pos(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.nullify\n"
      end
    end

    def revenge_remove_all_pos(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.nullify\n"
      end
    end

    def dodge(effect)
      amount = (effect['multiplier'] * 100).to_i
      probability = (effect['probability'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.add_modifier(Modifiers::Dodge.new(#{probability}, #{turns}, #{attacks}))\n"
      end
    end

    def crit_increase(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.add_modifier(Modifiers::IncreaseCriticalChance.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def taunt(effect)
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.add_modifier(Modifiers::Taunt.new(#{turns}, #{attacks}))\n"
      end
    end

    def revenge_taunt(effect)
      taunt(effect)
    end

    def remove_damage_decrease(effect)
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.cleanse(:distraction)\n"
      end
    end

    def remove_dodge(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.remove_dodge\n"
      end
    end

    def revenge_remove_dodge(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.remove_dodge\n"
      end
    end

    def remove_cloak(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.remove_cloak\n"
      end
    end

    def revenge_remove_cloak(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.remove_cloak\n"
      end
    end

    def remove_taunt(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.remove_taunt\n"
      end
    end

    def revenge_remove_taunt(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.remove_taunt\n"
      end
    end

    def remove_shield(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.destroy_shields\n"
      end
    end

    def revenge_remove_shield(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.destroy_shields\n"
      end
    end

    def remove_speed_increase(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.remove_speed_increase\n"
      end
    end

    def remove_damage_increase(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.remove_attack_increase\n"
      end
    end

    def revenge_remove_damage_increase(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.remove_attack_increase\n"
      end
    end

    def remove_crit_increase(effect)
      insert_into_file full_path, :after => "def update_defender(defender)\n" do
        "    defender.remove_critical_chance_increase\n"
      end
    end

    def revenge_remove_crit_increase(effect)
      insert_into_file full_path, :after => "def update_defender_revenge(defender)\n", :force => true do
        "    defender.remove_critical_chance_increase\n"
      end
    end

    def vulner(effect)
      amount = (effect['multiplier'] * 100).to_i
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_defender_after_damage(defender)\n" do
        "    defender.add_modifier(Modifiers::Vulnerability.new(#{amount}, #{turns}, #{attacks}))\n"
      end
    end

    def remove_vulner(effect)
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.cleanse(:vulnerable)\n"
      end
    end

    def revenge_remove_vulner(effect)
      insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n", :force => true do
        "    attacker.cleanse(:vulnerable)\n"
      end
    end

    def remove_dot(effect)
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.cleanse(:damage_over_time)\n"
      end
    end

    def revenge_remove_dot(effect)
      insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n", :force => true do
        "    attacker.cleanse(:damage_over_time)\n"
      end
    end

    def cloak(effect)
      damage = ((effect['multiplier'] - 1) * 100)
      probability = 75
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker(attacker)\n" do
        "    attacker.add_modifier(Modifiers::Cloak.new(#{probability}, #{damage}, #{turns}, #{attacks}))\n"
      end
    end

    def rend(effect)
      damage = effect['multiplier']
      gsub_file full_path, "self.is_rending_attack = false", "self.is_rending_attack = true"
      gsub_file full_path, "self.damage_multiplier = 0", "self.damage_multiplier = #{damage}"
    end

    def revenge_rend(effect)
      damage = effect['multiplier']
      gsub_file full_path, "self.is_rending_attack = false", "self.is_rending_attack = true"
      gsub_file full_path, "self.damage_multiplier = 0", "self.damage_multiplier = #{damage}"
    end

    def revenge_cloak(effect)
      damage = ((effect['multiplier'] - 1) * 100)
      probability = 75
      turns = effect['duration'][0]
      attacks = effect['duration'][1] || 'nil'
      insert_into_file full_path, :after => "def update_attacker_revenge(attacker)\n", :force => true do
        "    attacker.add_modifier(Modifiers::Cloak.new(#{probability}, #{damage}, #{turns}, #{attacks}))\n"
      end
    end

  end
end
end

class Utilities

  def self.deep_clone(dinosaur)
    result = Dinosaur2.new
    result.current_health = dinosaur.current_health
    result.is_stunned = dinosaur.is_stunned
    result.strategy = dinosaur.strategy
    result.value = dinosaur.value
    result.team = dinosaur.team
    result.is_revenge = dinosaur.is_revenge
    result.selected_ability = dinosaur.selected_ability
    result.health_26 = dinosaur.health_26
    result.damage_26 = dinosaur.damage_26
    result.speed = dinosaur.speed
    result.level = dinosaur.level
    result.resistances = dinosaur.resistances
    result.name = dinosaur.name
    result.armor = dinosaur.armor
    result.critical_chance = dinosaur.critical_chance
    result.attack_boosts = dinosaur.attack_boosts
    result.health_boosts = dinosaur.health_boosts
    result.speed_boosts = dinosaur.speed_boosts
    result.dna = dinosaur.dna
    result.color = dinosaur.color

    if dinosaur.abilities.is_a?(String)
      result.abilities = dinosaur.abilities
    else
      result.abilities = []
      dinosaur.abilities.each do |a|
        ability = a.class.new
        ability.current_cooldown = a.current_cooldown
        ability.current_delay = a.current_delay
        result.abilities << ability
      end
    end

    if dinosaur.abilities_counter.is_a?(String)
      result.abilities_counter = dinosaur.abilities_counter
    else
      result.abilities_counter = []
      dinosaur.abilities_counter.each do |a|
        ability = a.class.new
        result.abilities_counter << ability
      end
    end

    if dinosaur.abilities_on_escape.is_a?(String)
      result.abilities_on_escape = dinosaur.abilities_on_escape
    else
      result.abilities_on_escape = []
      dinosaur.abilities_on_escape.each do |a|
        ability = a.class.new
        result.abilities_on_escape << ability
      end
    end

    if dinosaur.abilities_swap_in.is_a?(String)
      result.abilities_swap_in = dinosaur.abilities_swap_in
    else
      result.abilities_swap_in = []
      dinosaur.abilities_swap_in.each do |a|
        ability = a.class.new
        result.abilities_swap_in << ability
      end
    end

    result.modifiers = []
    dinosaur.modifiers.each do |m|
      result.modifiers << m.dup
    end

    result
  end
end

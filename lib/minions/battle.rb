module Minions
  module Battle

    # Attributes for rendering simulations
    attr_accessor :color

    # Attributes needed during a fight
    attr_accessor :current_health
    attr_accessor :modifiers # same method, we instantiate modifiers and append them to this list.[decrease_speed]
    attr_accessor :is_stunned # when stunned, skip this attack and unstun.
    attr_accessor :strategy # single strategy to use
    attr_accessor :strategies # allow an array of strategies and choose one for each move
    attr_accessor :value # used during min max and other strategeis: self: 1.0, opponent -1.0
    attr_accessor :team # used in team matches & raids
    attr_accessor :is_revenge # trueif the dino swapped in for a dino that just died
    attr_accessor :selected_ability # stores the abiity selected for the next round, to simplify the code base

    # reset fight attributes, to initial values
    # also (re)-build the abilities from the classes passed in
    # ToDo: use stat bosts to calculate actual health, speed and damage
    def reset_attributes!
      @current_health = health
      @current_speed = speed
      @is_stunned = false
      @modifiers = []
      @is_revenge = false
      @selected_ability = nil
      # Instantiate the abilities
      self.abilities = self.abilities.map{|klass| klass.new} if self.abilities.first.class == Class
      self.abilities_swap_in = self.abilities_swap_in.map{|klass| klass.new} if self.abilities_swap_in.first.class == Class
      self.abilities_counter = self.abilities_counter.map{|klass| klass.new} if self.abilities_counter.first.class == Class
      self.abilities_on_escape = self.abilities_on_escape.map{|klass| klass.new} if self.abilities_on_escape.first.class == Class
      self
    end

    # pick a strategy
    def strategy
      if @strategies.nil?
        @strategy
      else
        @strategies.sample
      end
    end

    # calculate modifications to current attributes by collecting all active modifiers to the attributes
    # attributes are
    # speed, distraction, shields, damage, critical_chance, dodge
    # shields: 0 .. 100 (modification in percent)
    # speed: 0 .. 200 (cumulative modifers in percent)
    # damage: -100 .. 200 (cumulative modifiers in percent) damage = (100+this)/100 * original damage, use for attack increase
    # distraction: 0..100 (cumulative modifiers in percent)
    # critical chance: -100 .. +100 (cumulative modifiers in percent)
    # dodge: totoal chance due t dodge, so if create dodge 67% of damange, value is 67
    # damage_over_time: 0 (none) to x percent
    # TODO: decide the mechanism to use, this is currently a mix of two.
    # if percentage values: this is an absolute delta.
    def current_attributes
      attributes = {speed: 100, shields: 0, damage: 0, distraction: 0, dodge: 0, critical_chance: self.critical_chance, damage_over_time: 0, vulnerable: false }
      modifiers.each do |modifier|
        modifier.execute(attributes)
      end
      attributes
    end

    def current_speed
      [0, (speed_with_boosts * current_attributes[:speed] / 100).to_i].max
    end

    # attempt to add a modifiers
    def add_modifier(modifier)
      # unconditional at frist, TODO later take resistances into account
      modifiers << modifier
    end

    # for each attack modifier reduce count and delete if depleted
    def tick_attack_count
      modifiers.delete_if do |modifier|
        modifier.tick_when_attacking && modifier.tick_attacks
      end
    end

    # for each defense modifier reduce count and delete if depleted
    # example: shields that take a hit, get their count decremented
    def tick_defense_count
      modifiers.delete_if do |modifier|
        modifier.tick_when_attacked && modifier.tick_attacks
      end
    end

    # Distraction ticks down at the end of the affected dino's action, so the turn based mechanism does not work
    def tick_distraction
      modifiers.delete_if do |modifier|
        modifier.class == Modifiers::Distraction && modifier.tick
      end
    end

    # Shields tick down at top of the attacker's turn
    def tick_shields
      modifiers.delete_if do |modifier|
        modifier.class == Modifiers::Shields && modifier.tick
      end
    end

    # Dodge ticks down at top of the attacker's turn
    def tick_dodge
      modifiers.delete_if do |modifier|
        modifier.class == Modifiers::Dodge && modifier.tick
      end
    end

    # affects cooldown and delay of all abilities after each round
    # delay is only initially, cooldown only after a ability is used.
    # tick runs after all other updates
    def tick
      # Count down delay and cooldown of attacks
      abilities.each do |ability|
        ability.tick
      end
      # Count down modifiers and delete expired ones, except distraction, this is handled after each action
      modifiers.delete_if do |modifier|
        modifier.tick unless [Modifiers::Distraction, Modifiers::Shields, Modifiers::Dodge].include? modifier.class
      end
    end

    def apply_damage_over_time
      if current_attributes[:damage_over_time] != 0
        self.current_health -= (current_attributes[:damage_over_time] / 100.0 * self.health * (100.0 - self.resistance(:damage_over_time)) / 100.0).round
        self.current_health = 0 if self.current_health < 0
      end
    end

    # cleanse negative effects
    # it takes effect immeditately, not just at the next tick
    def cleanse(effect)
      modifiers.delete_if{|modifier| modifier.cleanse.include?(effect)}
    end

    # destroy the shields
    def destroy_shields
      modifiers.delete_if{|modifier| modifier.destroy.include?(:shields)}
    end

    # remove all positive effects
    def nullify
      modifiers.delete_if{|modifier| modifier.is_positive}
    end

    # remove taunt
    def remove_taunt
      modifiers.delete_if{|modifier| modifier.class == Modifiers::Taunt}
    end

    def remove_dodge
      modifiers.delete_if{|modifier| modifier.class == Modifiers::Dodge}
    end

    def remove_cloak
      modifiers.delete_if{|modifier| modifier.class == Modifiers::Cloak}
    end

    def remove_critical_chance_increase
      modifiers.delete_if{|modifier| modifier.class == Modifiers::IncreaseCriticalChance}
    end

    def remove_critical_chance_decrease
      modifiers.delete_if{|modifier| modifier.class == Modifiers::ReduceCriticalChance}
    end

    def remove_attack_increase
      modifiers.delete_if{|modifier| modifier.class == Modifiers::IncreaseDamage}
    end

    def remove_speed_increase
      modifiers.delete_if{|modifier| modifier.class == Modifiers::IncreaseSpeed}
    end

    def remove_speed_decrease
      modifiers.delete_if{|modifier| modifier.class == Modifiers::DecreaseSpeed}
    end

    # available abilities are those where both delay and cooldown is 0
    def available_abilities
      abilities.select {|ability| ability.is_available? && ability.is_implemented}
    end

    # Pick the next ability (need to add order dependency or strikes)
    # returns the instance
    # For now just return the first available ability defined later use strategies
    def pick_ability(attacker, defender)
      @selected_ability = strategy.next_move(attacker, defender)
    end

    def has_counter?
      !abilities_counter.empty?
    end

    def has_swap_in?
      !abilities_swap_in.empty?
    end


    # when swapping out, all cooldowns and delays get reset
    def reset_abilities
      abilities.each do |ability|
        ability.current_cooldown = 0
        ability.current_delay = ability.delay
      end
    end

    # returns the 'better' value from the point of view of the dinosaur
    def maximize(a, b)
      return b if a.nil?
      return a if b.nil?
      if self.value == 1.0
        return [a, b].max
      else
        return [a, b].min
      end
    end

    # returns the worse value from the point of view of the dinosaur
    def minimize(a, b)
      return b if a.nil?
      return a if b.nil?
      if self.value == 1.0
        return [a, b].min
      else
        return [a, b].max
      end
    end

    # Hash value for lookup tables etc.
    def hash_value
      result = "#{name} #{current_health} #{level} "
      abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
      modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
      result
    end

    # heal up to maximum of original health
    def heal(value)
      @current_health += value
      @current_health = health if current_health > health
    end

    # calculate health at specific level from level @ 26 includng stat boosts
    def health
      @health
    end

    # calculate damage at specific level from level @ 26 includng stat boosts
    def damage
      @damage
    end

    # calculate speed includng stat boosts
    def speed_with_boosts
      @speed
    end

    def resistance(symbol)
      if self.resistances.nil? || self.resistances.empty?
        return 0
      else
        index = Constants::RESISTANCES.find_index(symbol)
        return self.resistances[index]
      end
    end

  end
end

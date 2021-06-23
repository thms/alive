require 'logger'

class Dinosaur < ApplicationRecord

  belongs_to :left, class_name: 'Dinosaur', optional: true
  belongs_to :right, class_name: 'Dinosaur', optional: true

  # Storage format for abilities
  serialize :abilities
  serialize :abilities_swap_in
  serialize :abilities_counter
  serialize :abilities_on_escape

  # Storage format for resistances
  serialize :resistances

  # Filtering
  scope :filter_by_rarity, -> (rarity) { where rarity: rarity }
  scope :filter_by_is_implemented, -> (is_implemented) { where is_implemented: is_implemented }
  scope :order_by_dna, -> (direction) { order dna: direction }

  # Attributes for rendering simulations
  attr_accessor :color

  # Attributes needed during a fight
  attr_accessor :current_health
  # attr_accessor :current_speed
  attr_accessor :modifiers # same method, we instantiate modifiers and append them to this list.[decrease_speed]
  attr_accessor :is_stunned # when stunned, skip this attack and unstun.
  attr_accessor :strategy
  attr_accessor :value # used during min max and other strategeis: self: 1.0, opponent -1.0
  attr_accessor :team # used in team matches

  def to_param
    name.parameterize
  end
  # reset fight attributes, to initial values
  # also (re)-build the abilities from the classes passed in
  # ToDo: use stat bosts to calculate actual health, speed and damage
  def reset_attributes!
    @current_health = health
    @current_speed = speed
    @is_stunned = false
    @modifiers = []
    # Instantiate the abilities
    self.abilities = self.abilities.map{|klass| klass.new} if self.abilities.first.class == Class
    self.abilities_swap_in = self.abilities_swap_in.map{|klass| klass.new} if self.abilities_swap_in.first.class == Class
    self.abilities_counter = self.abilities_counter.map{|klass| klass.new} if self.abilities_counter.first.class == Class
    self.abilities_on_escape = self.abilities_on_escape.map{|klass| klass.new} if self.abilities_on_escape.first.class == Class
    self
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
    attributes = {speed: 100, shields: 0, damage: 0, distraction: 0, dodge: 0, critical_chance: self.critical_chance, damage_over_time: 0 }
    modifiers.each do |modifier|
      modifier.execute(attributes)
    end
    attributes
  end

  # ToDo: cap at zero, to prevent it from going negative?
  def current_speed
    (speed_with_boosts * current_attributes[:speed] / 100).to_i
  end

  # attempt to add a modifiers
  def add_modifier(modifier)
    # unconditional at frist, TODO later take resistances into account
    modifiers << modifier
  end

  # for each attack modifier reduce count and delete if depleted
  def tick_attack_count
    modifiers.delete_if do |modifier|
      modifier.is_attack && modifier.tick_attacks
    end
  end

  # for each defense modifier reduce count and delete if depleted
  # example: shields that take a hit, get their count decremented
  def tick_defense_count
    modifiers.delete_if do |modifier|
      modifier.is_defense && modifier.tick_attacks
    end
  end

  # affects cooldown and delay of all abilities after each round
  # delay is only initially, cooldown only after a ability is used.
  # tick runs after all other updates
  # TODO: implement DoT here, before modifers are couted down.
  def tick
    # Count down delay and cooldown of attacks
    abilities.each do |ability|
      ability.tick
    end
    # Apply damage over time, if any, taking resistance into account
    if current_attributes[:damage_over_time] != 0
      self.current_health -= (current_attributes[:damage_over_time] / 100.0 * self.health * (100.0 - self.resistance(:damage_over_time)) / 100.0).round
      self.current_health = 0 if self.current_health < 0
    end
    # Count down modifiers and delete expired ones
    modifiers.delete_if do |modifier|
      modifier.tick
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
    modifiers.delete_if{|modifier| modifier.class == Modifiers::Taunt}
    # TODO remmove other effects of dodge
  end

  def remove_critical_chance_increase
    modifiers.delete_if{|modifier| modifier.class == Modifiers::IncreaseCriticalChance}
  end

  def remove_attack_increase
  end

  def remove_speed_increase
    modifiers.delete_if{|modifier| modifier.class == Modifiers::IncreaseSpeed}
  end

  # available abilities are those where both delay and cooldown is 0
  def available_abilities
    abilities.select {|ability| ability.current_delay <= 0 && ability.current_cooldown == 0 && ability.is_implemented}
  end

  # Pick the next ability (need to add order dependency or strikes)
  # returns the instance
  # For now just return the first available ability defined later use strategies
  def pick_ability(attacker, defender)
    strategy.next_move(attacker, defender)
  end

  def has_counter?
    !abilities_counter.empty?
  end

  def has_swap_in?
    !abilities_swap_in.empty?
  end

  def has_on_escape?
    !abilities_on_escape.empty?
  end

  # can the dino swap out in the current state of the game
  # this is determined exclusively by an active swap_prevention modifer
  # two modes: if dino swaps in and swap rpevention is a consequence of that, resistance is not evaluated
  # if another dino lays swap prevention modifier, then resistance is evaluated
  def can_swap?
    if modifiers.any? {|modifier| modifier.class == Modifiers::PreventSwap && modifier.source == 'self'}
      # cannot swap if own swap-in resulted the swap prevention
      return false
    elsif modifiers.any? {|modifier| modifier.class == Modifiers::PreventSwap && modifier.source == 'other'}
      if rand(100) <= resistance(:swap_prevention)
        # can swap if other initated swap prevention and resistance is in its favor
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def run
    team.run
  end

  # Hash value for lookup tables etc.
  def hash_value
    result = "#{name} #{current_health} #{level} "
    abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    result
  end

  # caluclate health at specific level from level @ 26 includng stat boosts
  def health
    (health_26 * (100.0 + health_boosts * 2.5 + (level - 26) * 5.0) / 100.0).round
  end

  # caluclate damamge at specific level from level @ 26 includng stat boosts
  def damage
    (damage_26 * (100.0 + attack_boosts * 2.5 + (level - 26) * 5.0) / 100.0).round
  end

  # caluclate speed includng stat boosts
  def speed_with_boosts
    (speed * (100.0 + speed_boosts * 2.5) / 100.0).round
  end

  # returns array of all possible hybrids one level up
  def possible_hybrids
    [
      Dinosaur.where(left_id: id),
      Dinosaur.where(right_id: id)
    ].flatten
  end

  # returns names of all possible hybrids one level up
  def possible_hybrid_names
    possible_hybrids.map {|dinosaur| dinosaur.name}.to_sentence
  end

  # True if it has components
  def is_hybrid?
    (left_id && right_id) || (left && right)
  end

  # True if either component is a hybrid
  def is_super_hybrid?
    left.is_hybrid? || right.is_hybrid?
  end

  # Fuse two components up to N times, return the coins spent on the fusions and the number of fusions done
  # update components available DNA
  # checks is fusion is possible
  def fuse(requested_fusions = 1)
    result = {coins: 0, fusions: 0}
    if is_hybrid?
      # level components must be at
      component_target_level = Constants::MIN_LEVEL_OF_COMPONENTS_TO_FUSE[rarity.to_sym]
      # possible fusions:
      left_fusions = (left.dna / Constants::DNA_TO_FUSE[left.rarity.to_sym][self.rarity.to_sym].to_f).floor
      right_fusions = (right.dna / Constants::DNA_TO_FUSE[right.rarity.to_sym][self.rarity.to_sym].to_f).floor
      fusions = [left_fusions, right_fusions].min
      if (left.level < component_target_level) || (right.level < component_target_level) || fusions < 1
        return result
      end
      result[:coins] = fusions * Constants::COINS_TO_FUSE[rarity.to_sym]
      result[:fusions] = fusions
      self.dna += fusions * Constants::FUSION_AVERAGE_DNA
      left.dna -= fusions * Constants::DNA_TO_FUSE[left.rarity.to_sym][self.rarity.to_sym]
      right.dna -= fusions * Constants::DNA_TO_FUSE[right.rarity.to_sym][self.rarity.to_sym]
      return result
    else
      # not a hybrid, nothing to fuse.
      return result
    end
  end

  # Calculate the max level this can be evolved to, given the current DNA and levels of self and components
  def max_level_possible
    coins = 0
    dna_spent = 0
    max_level = self.level
    if is_hybrid?
      # min level components need to be at
      component_target_level = Constants::MIN_LEVEL_OF_COMPONENTS_TO_FUSE[rarity.to_sym]
      # dna needed to get to fusion level left
      if (left.level < component_target_level) && (left.dna_to_level(component_target_level) <= left.dna)
        # bring up to target level - if we have enough DNA
        left.dna -= left.dna_to_level(component_target_level)
        coins += left.coins_to_level(component_target_level)
        left.level = component_target_level
      end
      # now the dino is either at fusion level or not, if he is, calculate the number of fusions he can contribute
      if left.level >= component_target_level
        left_fusions = (left.dna / Constants::DNA_TO_FUSE[left.rarity.to_sym][self.rarity.to_sym].to_f).floor
      end
      # dna needed to get to fusion level right
      if (right.level < component_target_level) && (right.dna_to_level(component_target_level) <= right.dna)
        # bring up to target level - if we have enough DNA
        right.dna -= right.dna_to_level(component_target_level)
        coins += right.coins_to_level(component_target_level)
        right.level = component_target_level
      end
      # now the dino is either at fusion level or not, if he is, calculate the number of fusions he can contribute
      if right.level >= component_target_level
        right_fusions = (right.dna / Constants::DNA_TO_FUSE[right.rarity.to_sym][self.rarity.to_sym].to_f).floor
      end
      # how many fusions can we do:
      fusions = [left_fusions, right_fusions].min
      self.dna += fusions * Constants::FUSION_AVERAGE_DNA
      # how far can we evolve the hybrid?
      while self.dna >= Constants::DNA_TO_EVOLVE[rarity.to_sym][level]
        dna_for_step = Constants::DNA_TO_EVOLVE[rarity.to_sym][level]
        fusions_for_step = (dna_for_step / Constants::FUSION_AVERAGE_DNA.to_f).ceil
        self.dna -= dna_for_step
        # coins for the upgrade:
        coins += coins_to_level(level+1)
        # coins for the fusions used
        coins += fusions_for_step * Constants::COINS_TO_FUSE[rarity.to_sym]
        self.level += 1
      end
      max_level = self.level
    else # non-hybrid
      # iterate until DNA is used up
      dna_available = self.dna
      while Constants::DNA_TO_EVOLVE[rarity.to_sym][max_level] <= dna_available
        dna_available -= Constants::DNA_TO_EVOLVE[rarity.to_sym][max_level]
        dna_spent += Constants::DNA_TO_EVOLVE[rarity.to_sym][max_level]
        max_level += 1
      end
      coins = coins_to_level(max_level)
    end
    return {coins: coins, level: max_level, dna: dna_spent}
  end

  # Calculate the cost to create this recursively at its lowest possible level, including cost for all components
  # dimension is coins, dna
  def cost_to_create(dimension)
    target_level = Constants::STARTING_LEVELS[rarity.to_sym]
    cost_to_level(target_level)[dimension].inject(0) {|s, tuple| tuple[1] > 0 ? s+= tuple[1] : s}
  end

  # Recursion: the leafs are never hybrids, so straight-up
  # hybrids calculate their componets and add the own fusion cost.
  # target_dna: at target level, how much extra DNA needs to be there to allow fusions higher up in the tree?
  def cost_to_level(target_level, target_dna = 0, result = nil)
    # Initialise cost
    result = {
      coins: {},
      dna: {},
      fusions: {},
      target_levels: {}
    } unless result
    # Initialse to zero when not existing
    result[:coins][name] = 0 if result[:coins][name].nil?
    result[:dna][name] = 0 if result[:dna][name].nil?
    result[:fusions][name] = 0 if result[:fusions][name].nil?
    result[:target_levels][name] = target_level
    return result if level == 30
    if is_hybrid?
      # add coins to upgrade self after the fusions are done
      result[:coins][name] += coins_to_level(target_level).to_i

      # Since DNA will be contributed by the two components, this does not require extra DNA / double counting
      result[:dna][name] += 0

      # number of fusions needed to get the hybrid up to the target level plus addiiotnal DNA needed, plus direct cost of fusions
      fusions_needed = (( dna_to_level(target_level) + target_dna - dna)/ Constants::FUSION_AVERAGE_DNA.to_f).ceil
      result[:fusions][name] = fusions_needed
      result[:coins][name] += fusions_needed * Constants::COINS_TO_FUSE[rarity.to_sym]

      # target level for components, and dna each must have in addition to provide the fusions needed
      component_target_level = Constants::MIN_LEVEL_OF_COMPONENTS_TO_FUSE[rarity.to_sym]
      target_dna_left = fusions_needed * Constants::DNA_TO_FUSE[left.rarity.to_sym][rarity.to_sym]
      target_dna_right = fusions_needed * Constants::DNA_TO_FUSE[right.rarity.to_sym][rarity.to_sym]

      # Recursively calculate cost to get the components to the required level with the additional DNA needed for the fusions
      left.cost_to_level(component_target_level, target_dna_left, result)
      right.cost_to_level(component_target_level, target_dna_right, result)

    else
      cost_to_level_non_hybrid(target_level, target_dna, result)
    end
    result
  end

  def resistance(symbol)
    if self.resistances.nil? || self.resistances.empty?
      return 0
    else
      index = Constants::RESISTANCES.find_index(symbol)
      return self.resistances[index]
    end
  end

  private

  # Upgrade the dinosaur N levels
  # Only looks at own DNA available, intended as a base operation
  def evolve(requested_levels = 1)
    result = {coins: 0, levels: 0}
    target_level = self.level + requested_levels
    while self.dna >= Constants::DNA_TO_EVOLVE[rarity.to_sym][level] && self.level < target_level
      result[:levels] += 1
      result[:coins] += Constants::COINS_TO_EVOLVE[level]
      self.dna -= Constants::DNA_TO_EVOLVE[rarity.to_sym][level]
      self.level += 1
    end
    result
  end




  # Returns the cost to get to a non-hybrid to a specific level & DNA on hand
  def cost_to_level_non_hybrid(target_level, target_dna, result)
    # Self only.
    result[:coins][name] = coins_to_level(target_level) || 0
    result[:dna][name] = dna_to_level(target_level) + target_dna - dna
    result[:fusions][name] = 0
    result[:target_levels][name] = target_level
  end

  # returns the cost in DNA to reach a given level for this dinosaur, from the current level, only looks at self, not components
  def dna_to_level(target_level)

    if (target_level <= level)
      0 # no cost if we are at target level already
    else
      Constants::DNA_TO_EVOLVE[rarity.to_sym][level .. target_level - 1].inject(:+)
    end
  end

  # returns the cost in coins to reach a given level for this dinosaur, from the current level, only looks at self, not components
  def coins_to_level(target_level)
    # Self only, if the dinsoaur is not yet created, need to skip the levels to the one where it will be created at
    if (target_level <= level)
      0
    elsif level == 0
      start_level = Constants::STARTING_LEVELS[rarity.to_sym]
      Constants::COINS_TO_EVOLVE[start_level .. target_level - 1].inject(:+)
    else
      Constants::COINS_TO_EVOLVE[level .. target_level - 1].inject(:+)
    end
  end

end

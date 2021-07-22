# describes the game mechanics and steps to take
module Mechanics


  def attack(attacker, defender, log, logger)
    swapped_out = nil
    if attacker.is_stunned
      logger.info("#{attacker.name} is stunned")
      # update cooldown on what the attacker selected, even if he did not get around to use it
      attacker.selected_ability.update_cooldown_attacker(attacker, defender)
      # replace with do nothing ability
      attacker.selected_ability = IsStunned.new
    end
    hit_stats = attacker.selected_ability.execute(attacker, defender)
    log << {event: "#{attacker.name}::#{attacker.selected_ability.class}", stats: hit_stats, health: health([attacker, defender])}
    logger.info("#{attacker.name}: #{attacker.selected_ability.class}")
    swapped_out = attacker.name if attacker.selected_ability.is_swap_out
    logger.info("#{attacker.name}: swapped_out") unless swapped_out.nil?
    return hit_stats, swapped_out
  end

  # returns true if the match has ended, false otherwise
  def has_ended?(dinosaurs)
    dinosaurs.any? {|d| d.current_health == 0}
  end

  def determine_outcome(dinosaurs, swapped_out, log)
    # four possible outcomes: draw, d1 wins, d2 wins, one dino swapped out
    if dinosaurs.all? {|d| d.current_health == 0}
      outcome = 'draw'
      outcome_value = Constants::MATCH[:draw]
    elsif dinosaurs.any? {|d| d.current_health == 0}
      outcome = dinosaurs.first.current_health > 0 ? "#{dinosaurs.first.name}" : "#{dinosaurs.last.name}"
      outcome_value = dinosaurs.first.current_health > 0 ? "#{dinosaurs.first.value}" : "#{dinosaurs.last.value}"
    elsif !swapped_out.nil?
      outcome = "#{swapped_out} swapped out"
      outcome_value  = Constants::MATCH[:swap_out] * (dinosaurs.first.name == swapped_out ? dinosaurs.first.value : dinosaurs.last.value)
    end
    # write the outcome log entry
    log << {event: outcome, stats: {}, health: health(dinosaurs)}
    {outcome: outcome, outcome_value: outcome_value, log: log}
  end

  # faster dinosaur wins, if both are equal use level, then random (in games: who pressed faster)
  def order_dinosaurs(dinosaurs)
    if dinosaurs.first.current_speed == dinosaurs.last.current_speed
      retval = dinosaurs.first.level > dinosaurs.last.level ? dinosaurs : dinosaurs.reverse!
      retval.shuffle! if dinosaurs.first.level == dinosaurs.last.level
    else
      retval = dinosaurs.first.current_speed > dinosaurs.last.current_speed ? dinosaurs : dinosaurs.reverse!
    end
    # if the second picked priority move and the first one did not, swap them around
    # in all other cases they are already in the correct order
    if retval.last.selected_ability.is_priority && !retval.first.selected_ability.is_priority
      retval.reverse!
    end
    retval
  end

  def health(dinosaurs)
    if dinosaurs.first.name < dinosaurs.last.name
      return "#{dinosaurs.first.name}:#{dinosaurs.first.current_health}, #{dinosaurs.last.name}:#{dinosaurs.last.current_health}"
    else
      return "#{dinosaurs.last.name}:#{dinosaurs.last.current_health}, #{dinosaurs.first.name}:#{dinosaurs.first.current_health}"
    end
  end

  def hash_value(dinosaurs)
    "#{dinosaurs.first.value} #{dinosaurs.first.hash_value} #{dinosaurs.last.value} #{dinosaurs.last.hash_value}"
  end

  def apply_damage_over_time(dinosaurs)
    dinosaurs.first.apply_damage_over_time
    dinosaurs.last.apply_damage_over_time
  end

  # Move the clock
  # Update abilities' delay and cooldown counts
  # Update / expire effects on self and opponents
  def tick(dinosaurs)
    dinosaurs.first.tick
    dinosaurs.last.tick
  end








# # only if there is a previous dinosaur on the team and it survived
# def dinosaur.on_swap_in
#   self.selected_ability = abilties.swap_in.first || Abilites::SwapIn
# end
#
# def dinosaur/team.attempt_to_swap
#   if dinosaur.can_swap?
#     dinosaur.on_swap_out
#     pick next dinosaur
#   else
#     # do nothing
#   end
# end
#
# # call if the swap out succeeds
# def dinosaur.on_swap_out
#   self.abilities.swap_out.first.execute
# end
#
#
# def dinosaur.on_run
# end

end

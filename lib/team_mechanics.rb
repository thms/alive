require 'logger'
class TeamMechanics

  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn

  # attacker and defender are the current dinosaurs of each team, not the entire team
  # this only deals with single attacks and swap in when an on_escape ability was used
  # it does not deal with the round ending when the other has died.
  def self.attack(attacker, defender, log, events)
    # on the first attack of a dinosaur the recent-dinosaur must be reset to allow swapping in
    attacker.team.recent_dinosaur = nil
    if attacker.is_stunned
      # do not start cooldown on what the attacker selected,  if he did not get around to use it
      # instead execute do nothing ability
      hit_stats = IsStunned.new.execute(attacker, defender)

      log << {event: "#{attacker.name}::stunned", stats: hit_stats, health: Mechanics.health([attacker, defender])}
      events << {event: "#{attacker.name}::stunned", stats:hit_stats, health: Mechanics.health([attacker, defender])}
      EventSink.add "#{attacker.name}::stunned"

    else
      hit_stats = attacker.selected_ability.execute(attacker, defender)
      log << {event: "#{attacker.name}::#{attacker.selected_ability.class}", stats: hit_stats, health: Mechanics.health([attacker, defender])}
      events << {event: "#{attacker.name}::#{attacker.selected_ability.class}", stats: hit_stats, health: Mechanics.health([attacker, defender])}
      EventSink.add "#{attacker.name}::#{attacker.selected_ability.class}"

      if attacker.selected_ability.is_swap_out
        team = attacker.team
        name = attacker.name
        if defender.has_on_escape?
          EventSink.add "#{defender.name}::#{defender.abilities_on_escape.first.class}"
          defender.abilities_on_escape.first.execute(defender, attacker)
        end
        @@logger.info "Attempt to run: #{attacker.name}"
        if attacker.try_to_run
          # if the attacker manages to run, the team has a new current dinosaur, make him the attacker
          attacker = team.current_dinosaur
          events << {event: "#{name} swapped out", stats: {}, health: Mechanics.health([attacker, defender])}
        else
          # the attacker was prevented from swapping out
          events << {event: "#{name} prevented from swapping out", stats: {}, health: Mechanics.health([attacker, defender])}
        end
      end
    end
  end

  def self.has_ended?(attacker_team, defender_team, mode)
    is_win?(attacker_team, defender_team, mode) || is_draw?(attacker_team, defender_team, mode)
  end
  # Is the current state a win for one of the teams?
  # attacker and defender are the respective teams
  def self.is_win?(attacker_team, defender_team, mode)
    attacker_team.is_defeated?(mode) ^ defender_team.is_defeated?(mode)
  end

  # is the current state a draw this can happen in due to damage over time
  def self.is_draw?(attacker_team, defender_team, mode)
    attacker_team.is_defeated?(mode) && defender_team.is_defeated?(mode)
  end

  def self.determine_outcome(attacker, defender, mode)
    if is_draw?(attacker, defender, mode)
      outcome = 'draw'
      outcome_value = Constants::MATCH[:draw]
    elsif is_win?(attacker, defender, mode)
      outcome = attacker.is_defeated?(mode) ? "#{defender.name}" : "#{attacker.name}"
      outcome_value = attacker.is_defeated?(mode) ? defender.value : attacker.value
    else
      outcome = ""
      outcome_value = nil
    end
    return outcome, outcome_value
  end


end

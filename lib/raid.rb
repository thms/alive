require 'logger'

# Implements a raid battle between two teams

class Raid

  TURNS = 20 # max number of turns before a raid is ended.
  attr_accessor :attacker
  attr_accessor :defender
  attr_accessor :logger
  attr_accessor :log
  attr_accessor :round
  attr_accessor :mode # :pvp, :campaign, :raid
  attr_accessor :total_rounds
  attr_accessor :current_round
  attr_accessor :current_turn

  # attacker: always raid_team of regular dinosaurs
  # defender: always raid_team of boss + optional minions
  def initialize(attacker, defender)
    @attacker = attacker.reset_attributes!
    @attacker.value = Constants::MATCH[:max_player]
    @defender = defender.reset_attributes!
    @defender.value = Constants::MATCH[:min_player]
    @current_turn = 1
    @current_round = 1
    @total_rounds = @defender.boss.total_rounds
    @logger = Logger.new(STDOUT)
    @logger.level = :info
    @log = [] # ["T1:D1::Strike", "T2:D2::CleansingStrike", ...]
    @events = []
  end

  def execute
  end

  # call on top of a round to set up the new round
  # minions get completely refreshed and all modifiers removed
  # bosss gets health restored, but modifiers are staying in place.
  # boss index to abilities gets reset.
  def on_new_round
    @defender.revive_minions
    @defender.boss.current_health = @defender.boss.health
    @defender.boss.ability_index = 1
  end

  def has_round_ended?
    (@current_round != @total_rounds && @defender.boss.current_health == 0)
  end

  def has_raid_ended?
    (@current_round == @total_rounds && @defender.boss.current_health == 0) ||
    (@attacker.healthy_members)
  end


end

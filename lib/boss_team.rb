require 'logger'

# Represents a boss's team in a raid
class BossTeam < Team

  attr_accessor :logger
  def initialize(name, boss, minions = [])
    super(name, [boss, minions].flatten)
    @logger = Logger.new(STDOUT)
    @logger.info Minion.count
  end

  def boss
    @dinosaurs.first
  end

  def minions
    @dinosaurs[1..2]
  end

  def has_minions?
    @dinosaurs.size > 1
  end

  def reset_attributes!
    @logger.info(@dinosaurs)
    if @dinosaurs.first.class == String
      @dinosaurs[0] = Boss.find_by_name(@dinosaurs[0])
      @dinosaurs[1..2].map! {|minion| Minion.find_by_name(minion)}
    end
    @logger.info(@dinosaurs)
    @dinosaurs.each do |dinosaur|
      dinosaur.reset_attributes!
      dinosaur.color = @color
      dinosaur.team = self
      dinosaur.value = @value
    end
    self
  end



  # if there are minions, all their attributes are reset, modifiers are removed
  def revive_minions
    minions.each do |minion|
      minion.reset_attributes!
    end
  end

end

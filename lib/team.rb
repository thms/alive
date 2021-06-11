require 'logger'

# Represents a team in a 4:4 match

class Team

  attr_accessor :name
  attr_accessor :dinosaurs  # the four members as an array
  attr_accessor :value      # the value 1.0 || -1.0
  attr_accessor :strategy   # the team strategy
  attr_accessor :current_dinosaur # the one currently fighting
  attr_accessor :recent_dinosaur # keeps track of current dinossaur when he was forced to swap out, so we cannot swap him in again
  attr_accessor :logger
  attr_accessor :log

  def initialize(name, dinosaurs)
    @name = name
    @dinosaurs = dinosaurs
    @value = 1.0
    @strategy = nil
    @current_dinosaur = nil
    @recent_dinosaur = nil
    @logger = Logger.new(STDOUT)
    @logger.level = 1
  end

  def reset_attributes!
    @dinosaurs.each do |dinosaur|
      dinosaur.reset_attributes!
    end
    self
  end

  # pick the next dinosaur to enter the arena
  # used for initial selection and during swap, when a dino has died
  def next_dinosaur(opponent)
    @strategy.next_dinosaur(self, opponent)
    @current_dinosaur
  end

  # number of alive dinosaurs
  def current_health
    available_dinosaurs.size
  end

  # all dinosaurs with current_health > 0
  def available_dinosaurs
    @dinosaurs.select {|d| d.current_health > 0}
  end

  # swap out current for a new one
  def swap(new_dinosaur)
    @logger.info("#{@name} is swapping #{@current_dinosaur.try(:name)} for #{new_dinosaur.try(:name)} with recent: #{@recent_dinosaur.try(:name)}")
    unless @current_dinosaur.nil?
      # remove all modifiers
      @current_dinosaur.modifiers = []
      # remove stun
      @current_dinosaur.is_stunned = false
    end
    @recent_dinosaur = @current_dinosaur
    @current_dinosaur = new_dinosaur
  end

  # select the next move based on the strategy
  # decide to either use an ability of the current dinosaur
  # or a swap for another dinosaur
  def next_move(opponent)
    ability = @strategy.next_move(self, opponent)
  end

  def health
    @dinosaurs.map {|d| [d.name, d.current_health]}.to_h
  end
end

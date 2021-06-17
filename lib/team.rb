require 'logger'

# Represents a team in a 4:4 match (or any other number of opponents)

class Team

  attr_accessor :name
  attr_accessor :dinosaurs  # the four members as an array
  attr_accessor :value      # the value 1.0 || -1.0
  attr_accessor :strategy   # the team strategy
  attr_accessor :current_dinosaur # the one currently fighting
  attr_accessor :recent_dinosaur # keeps track of current dinossaur when he was forced to swap out, so we cannot swap him in again
  attr_accessor :logger
  attr_accessor :log
  attr_accessor :color

  def initialize(name, dinosaurs)
    @name = name
    @dinosaurs = dinosaurs
    @value = Constants::MATCH[:max_player]
    @strategy = nil
    @current_dinosaur = nil
    @recent_dinosaur = nil
    @logger = Logger.new(STDOUT)
    @logger.level = 1
  end

  def reset_attributes!
    if @dinosaurs.first.class == String
      @dinosaurs.map! {|name| Dinosaur.find_by_name(name)}
    end
    @dinosaurs.each do |dinosaur|
      dinosaur.reset_attributes!
      dinosaur.color = @color
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
  def healthy_members
    available_dinosaurs.size
  end

  # all dinosaurs with current_health > 0
  def available_dinosaurs
    @dinosaurs.select {|d| d.current_health > 0}
  end

  def can_swap?
    (current_dinosaur.nil? || current_dinosaur.can_swap? ) && (available_dinosaurs - [@current_dinosaur]).count > 0
  end

  # this may fail, e.g. if the dinosaur cannot swap
  # after: current_dinosaur is set to either the new or the old one
  # returns {has_swapped: true, was_healthy: false} if the swap was successfuly
  def swap(target_dinosaur, target_ability)
    was_healthy = @current_dinosaur.current_health > 0 rescue false
    retval = {has_swapped: false, was_healthy: was_healthy, ability: target_ability}
    if can_swap?
      retval[:has_swapped] = true
      unless @current_dinosaur.nil?
        # remove all modifiers
        @current_dinosaur.modifiers = []
        # remove stun
        @current_dinosaur.is_stunned = false
      end
      @recent_dinosaur = @current_dinosaur
      @current_dinosaur = target_dinosaur
      if was_healthy
        retval[:ability] = @current_dinosaur.has_swap_in? ? @current_dinosaur.abilities_swap_in.first : SwapIn.new
      end
    else
      # if swapping is denied for some reason the dinosaur looses this turn's ability
      retval[:ability] = SwapFailed.new
    end
    return retval
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

  def hash_value
    @dinosaurs.map {|d| d.hash_value}.to_sentence
  end
end

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
    @dinosaurs = dinosaurs.clone
    @value = Constants::MATCH[:max_player]
    @strategy = nil
    @current_dinosaur = nil
    @recent_dinosaur = nil
    @logger = Logger.new(STDOUT)
    @logger.level = :warn
  end

  def reset_attributes!
    if @dinosaurs.first.class == String
      @dinosaurs.map! {|name| Dinosaur.find_by_name(name)}
    end
    @dinosaurs.each do |dinosaur|
      dinosaur.reset_attributes!
      dinosaur.color = @color
      dinosaur.team = self
      dinosaur.value = @value
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
    healthy_dinosaurs.size
  end

  # all dinosaurs with current_health > 0
  def healthy_dinosaurs
    @dinosaurs.select {|d| d.current_health > 0}
  end

  # depending on the mode a team is defeated if a set number of dinos are dead
  def is_defeated?(mode)
    if dinosaurs.size == 1 && healthy_members == 0
      return true
    elsif dinosaurs.size == 1 && healthy_members == 1
      return false
    elsif mode == :raid && healthy_members == 0
      return true
    elsif (mode == :pvp || mode == :campaign) && healthy_members == 1
      return true
    else
      return false
    end
  end

  # all available dinosaurs, this excludes the recently swapped out, becuase we cannot swap to him
  def available_dinosaurs
    healthy_dinosaurs - [@recent_dinosaur]
  end

  def can_swap?
    (current_dinosaur.nil? || current_dinosaur.can_swap? ) && (available_dinosaurs - [@current_dinosaur]).count > 0
  end

  # Called from swap out abilities to try and run away. This may fail
  def run
    EventSink.add("#{current_dinosaur.name} tries to run")
    if can_swap?
      EventSink.add("#{current_dinosaur.name} managed to run")
      # make sure we cannot swap the same dinosaur in right away again and force next available dinosaur in order
      @recent_dinosaur = @current_dinosaur
      @current_dinosaur = next_available_dinosaur
      return true
    else
      # do nothing, not allowed to swap
      EventSink.add("#{current_dinosaur.name} failed to run")
      return false
    end
  end

  # pick the one on the right in the array, with modulo
  def next_available_dinosaur
    dinos = dinosaurs.clone
    dinos.delete_if {|d| d.current_health <= 0 && d != @current_dinosaur}
    current_index = dinos.find_index(@current_dinosaur)
    next_index = (current_index + 1).modulo(dinos.size)
    dinos[next_index]
  end


  # this may fail, e.g. if the dinosaur cannot swap
  # after: current_dinosaur is set to either the new or the old one
  # returns {has_swapped: true, was_healthy: false} if the swap was successfuly
  def swap(target_dinosaur, target_ability)
    was_healthy = @current_dinosaur.current_health > 0 rescue false
    is_revenge = @current_dinosaur && @current_dinosaur.current_health <= 0
    retval = {has_swapped: false, was_healthy: was_healthy, ability: target_ability}

    if can_swap?
      EventSink.add("Swapped to #{target_dinosaur.name}")
      retval[:has_swapped] = true
      unless @current_dinosaur.nil?
        # remove all modifiers
        @current_dinosaur.modifiers = []
        # remove stun
        @current_dinosaur.is_stunned = false
        # remove revenge
        @current_dinosaur.is_revenge = false
      end
      @recent_dinosaur = nil # @current_dinosaur
      @current_dinosaur = target_dinosaur
      if was_healthy
        retval[:ability] = @current_dinosaur.has_swap_in? ? @current_dinosaur.abilities_swap_in.first : SwapIn.new
      end
      if is_revenge
        @current_dinosaur.is_revenge = true
      end
    else
      # if swapping is denied for some reason the dinosaur looses this turn's ability
      EventSink.add("Swap to #{target_dinosaur.name} failed")
      retval[:ability] = SwapFailed.new
    end
    return retval
  end


  # select the next move based on the strategy
  # decide to either use an ability of the current dinosaur
  # or a swap for another dinosaur
  def next_move(opponent)
    ability = @strategy.next_move(self, opponent)
    EventSink.add "#{name} picked #{ability.class.name}"
    ability
  end

  def health
    @dinosaurs.map {|d| [d.name, d.current_health]}.to_h
  end

  def hash_value
    @dinosaurs.map {|d| d.hash_value}.to_sentence
  end
end

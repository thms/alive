require 'logger'
require 'dinosaurs/battle'

# this class mirrors the normal dinosaur active record class, but without the overhead of active record
# making it 10x faster to marshal
class Dinosaur2

  include Dinosaurs::Battle

  # These are the active record attributes
  attr_accessor :abilities
  attr_accessor :abilities_on_escape
  attr_accessor :abilities_counter
  attr_accessor :abilities_swap_in

  attr_accessor :current_health
  attr_accessor :health_26
  attr_accessor :damage_26
  attr_accessor :speed
  attr_accessor :level
  attr_accessor :resistances
  attr_accessor :name
  attr_accessor :armor
  attr_accessor :critical_chance
  attr_accessor :attack_boosts
  attr_accessor :health_boosts
  attr_accessor :speed_boosts
  attr_accessor :dna

end

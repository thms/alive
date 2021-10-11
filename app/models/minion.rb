require 'logger'
require 'dinosaurs/battle'
class Minion < ApplicationRecord

  include Minions::Battle

  belongs_to :boss

  # Storage format for abilities
  serialize :abilities
  serialize :abilities_counter

  # Storage format for resistances
  serialize :resistances


  def to_param
    name.parameterize
  end

end

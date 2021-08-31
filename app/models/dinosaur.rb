require 'logger'
require 'dinosaurs/fusion'
require 'dinosaurs/battle'
class Dinosaur < ApplicationRecord

  include Dinosaurs::Fusion
  include Dinosaurs::Battle

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

  def to_param
    name.parameterize
  end

end

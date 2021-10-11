require 'logger'
require 'bosses/battle'
class Boss < ApplicationRecord

  include Bosses::Battle

  has_many :minions

  # Storage format for abilities
  serialize :abilities
  serialize :abilities_counter

  # Storage format for resistances
  serialize :resistances

  def to_param
    name.parameterize
  end

end

# If it is possible to heal do that
class HealWhenPossibleStrategy

  HEALING_ABILITIES = ['heal','adrenaline', 'dig', 'refresh']

  def self.next_move(attacker, defender)
    # select abilities where the name includes at least one word from the array of healing options
    abilities = attacker.available_abilities.select {|ability| HEALING_ABILITIES.map {|kw| ability.class.name.downcase.include? kw}.any?}
    # and pick the last one, it shouldbe more potent
    # TODO: refine selection if more than one is available
    ability = abilities.last
    # fallback on random, if nothing matches
    if abilities.empty?
      return attacker.available_abilities.sample
    else
      return ability
    end
  end

end

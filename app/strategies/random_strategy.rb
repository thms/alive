# Really for testing only, pick a random available ability
class RandomStrategy < Strategy

  def self.next_move(attacker, defender)
    attacker.available_abilities.sample
  end
end

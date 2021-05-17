# Really for testing only, pick a random available ability
class RandomStrategy

  def self.next_move(available_abilities)
    available_abilities.sample
  end
end

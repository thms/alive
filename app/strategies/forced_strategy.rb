# Really for testing only, force a sequence of moves
class ForcedStrategy < Strategy

  @@moves = {'Dracoceratops' => ['CleansingImpact', 'FierceImpact'], 'Suchotator' => ['LethalWound', 'SuperiorityStrike']}
  def self.next_move(attacker, defender)
    move = @@moves[attacker.name].shift
    attacker.available_abilities.select {|a| a.class.name == move}.first
  end

  def self.reset
    @@moves = {'Dracoceratops' => ['CleansingImpact', 'FierceImpact'], 'Suchotator' => ['LethalWound', 'SuperiorityStrike']}
  end
end

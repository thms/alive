class TeamStrategy

  # Return one of the available dinosaurs
  def next_dinosaur(team1, team2)
  end

  # Set or swap the current dinosaur and return an available ability of the current dinosaur
  def next_move(team1, team2)
  end

  # Interface for learning from the outcome of a match
  def self.learn(outcome)
  end

end

class Modifiers::IncreaseSpeed < Modifiers::Modifier

  self.cleanse = []
  self.is_defense = true
  self.is_attack = !self.is_defense

end

# Base class for modifiers
# while they take the input and change it, they also need to keep track of turns and attacks.
# Phases of processing
#
class Modifiers::Modifier

  class_attribute :turns # number of turns this is active
  class_attribute :attacks # number of attacks this is active
  class_attribute :target # {self, opponent}
  class_attribute :probability # { in percent, 0 - 100}
  # if it has a probability, i.e. chance to dodge damage, calculate

  def execute(attributes)
    attributes.dup
  end
end

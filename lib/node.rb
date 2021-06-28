class Node

  attr_accessor :name
  attr_accessor :ability_name
  attr_accessor :children
  attr_accessor :parent
  attr_accessor :data
  attr_accessor :visits
  attr_accessor :is_final
  attr_accessor :winner
  attr_accessor :looser
  attr_accessor :color
  attr_accessor :id
  attr_accessor :value

  def initialize(name, ability_name = '', data = nil)
    @name = name
    @ability_name = ability_name
    @data = data
    @children = []
    @parent = nil
    @visits = 1
    @is_final = false
    @winner = nil
    @value = nil
    @looser = nil
    @id = SecureRandom.uuid[0..7]
  end

  def is_root?
    @parent.nil?
  end

  def root
    root = self
    root  = root.parent until root.is_root?
    root
  end

  def is_leaf?
    !has_children?
  end

  def has_children?
    @children.length != 0
  end

  def add_child(name, ability_name, data)
    node = Node.new(name, ability_name, data)
    node.parent = self
    children << node
    node
  end

  # adds a child node unless one with the same name already exists
  def add_or_update_child(name, ability_name, data)
    if child = children.find {|child| child.name == name}
      child.visits += 1
      return child
    else
      children << Node.new(name, ability_name, data)
      return children.last
    end
  end

  def to_s
    "#{@name} - #{@id}"
  end

  # calculate a uniqe hash value for the state of the game represented by the node
  # to use in the MinMaxStrategy to speed things up
  # Need: names of both, health of both, modifier names * tick count, ability names and cooldown/delay, levels, damage,
  def hash_value
    d = @data[:dinosaur1]
    result = "#{d.name} #{d.current_health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    d = @data[:dinosaur2]
    result << "#{d.name} #{d.current_health} #{d.level} "
    d.abilities.each {|a| result << "#{a.class.name} #{a.current_cooldown} #{a.current_delay} " }
    d.modifiers.each {|m| result << "#{m.class.name} #{m.current_turns} #{m.current_attacks} " }
    result
  end
end

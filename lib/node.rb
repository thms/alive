class Node

  attr_accessor :name
  attr_accessor :children
  attr_accessor :parent
  attr_accessor :data
  attr_accessor :visits
  attr_accessor :is_win
  attr_accessor :winner
  attr_accessor :color
  attr_accessor :id

  def initialize(name, data = nil)
    @name = name
    @data = data
    @children = []
    @parent = nil
    @visits = 1
    @is_win = false
    @winner = nil
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

  def add_child(node)
    children << node
    node
  end

  # adds a child node unless one with the same name already exists
  def add_or_update_child(name, data)
    if child = children.find {|child| child.name == name}
      child.visits += 1
      return child
    else
      children << Node.new(name, data)
      return children.last
    end
  end

  def to_s
    "#{@name} - #{@id}"
  end
end

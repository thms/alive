require 'logger'
class RaidMechanics

  @@logger = Logger.new(STDOUT)
  @@logger.level = :warn


  def self.attack
  end

  def self.order_dinosaurs(dinosaurs)
    dinosaurs.sort_by! {|d| [d.selected_ability.is_priority, d.speed, d.level]}
  end
end

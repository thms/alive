ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def create_team(health, damage, speed, level, name, abilities, abilities_counter, strategy)
    d1 = Dinosaur.new(health: health, damage: damage, speed: speed, level: level, name: "#{name}-1", abilities: abilities, abilities_counter: abilities_counter)
    d2 = Dinosaur.new(health: health, damage: damage, speed: speed, level: level, name: "#{name}-2", abilities: abilities, abilities_counter: abilities_counter)
    d3 = Dinosaur.new(health: health, damage: damage, speed: speed, level: level, name: "#{name}-3", abilities: abilities, abilities_counter: abilities_counter)
    d4 = Dinosaur.new(health: health, damage: damage, speed: speed, level: level, name: "#{name}-4", abilities: abilities, abilities_counter: abilities_counter)
    team = Team.new(name, [d1, d2, d3, d4])
    team.strategy = strategy
    team
  end

end

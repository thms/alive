require 'test_helper'
require 'generators/ability/ability_generator'

class AbilityGeneratorTest < Rails::Generators::TestCase
  tests AbilityGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end

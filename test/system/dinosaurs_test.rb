require "application_system_test_case"

class DinosaursTest < ApplicationSystemTestCase
  setup do
    @dinosaur = dinosaurs(:two)
  end

  test "visiting the index" do
    visit dinosaurs_url
    assert_selector "h1", text: "Dinosaurs"
  end

  test "creating a Dinosaur" do
    visit dinosaurs_url
    click_on "New Dinosaur"

    fill_in "Damage 26", with: @dinosaur.damage_26
    fill_in "Health 26", with: @dinosaur.health_26
    select "", from: "dinosaur[left_id]"
    select "", from: "dinosaur[right_id]"
    fill_in "Level", with: @dinosaur.level
    fill_in "Name", with: @dinosaur.name
    select @dinosaur.rarity, from: "dinosaur[rarity]"
    fill_in "Speed", with: @dinosaur.speed
    fill_in "Dna", with: @dinosaur.dna
    click_on "Create Dinosaur"

    assert_text "Dinosaur was successfully created"
    click_on "Back"
  end

  test "updating a Dinosaur" do
    visit dinosaurs_url
    click_on "Edit", match: :first

    fill_in "Damage 26", with: @dinosaur.damage_26
    fill_in "Health 26", with: @dinosaur.health_26
    select "", from: "dinosaur[left_id]"
    select "", from: "dinosaur[right_id]"
    fill_in "Level", with: @dinosaur.level
    fill_in "Name", with: @dinosaur.name
    select @dinosaur.rarity, from:  "dinosaur[rarity]"
    fill_in "Speed", with: @dinosaur.speed
    fill_in "Dna", with: @dinosaur.dna
    click_on "Update Dinosaur"

    assert_text "Dinosaur was successfully updated"
    click_on "Back"
  end

  test "destroying a Dinosaur" do
    visit dinosaurs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Dinosaur was successfully destroyed"
  end
end

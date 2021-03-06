require 'test_helper'

class DinosaursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dinosaur = dinosaurs(:one)
  end

  test "should get index" do
    get dinosaurs_url
    assert_response :success
  end

  test "should get new" do
    get new_dinosaur_url
    assert_response :success
  end

  test "should create dinosaur" do
    assert_difference('Dinosaur.count') do
      post dinosaurs_url, params: { dinosaur: { damage: @dinosaur.damage, health: @dinosaur.health, left: @dinosaur.left, level: @dinosaur.level, name: @dinosaur.name, rarity: @dinosaur.rarity, right: @dinosaur.right, speed: @dinosaur.speed, armor: @dinosaur.armor, critical_chance: @dinosaur.critical_chance } }
    end

    assert_redirected_to dinosaur_url(Dinosaur.last)
  end

  test "should show dinosaur" do
    get dinosaur_url(@dinosaur)
    assert_response :success
  end

  test "should get edit" do
    get edit_dinosaur_url(@dinosaur)
    assert_response :success
  end

  test "should update dinosaur" do
    patch dinosaur_url(@dinosaur), params: { dinosaur: { damage: @dinosaur.damage, health: @dinosaur.health, left: @dinosaur.left, level: @dinosaur.level, name: @dinosaur.name, rarity: @dinosaur.rarity, right: @dinosaur.right, speed: @dinosaur.speed, armor: @dinosaur.armor, critical_chance: @dinosaur.critical_chance } }
    assert_redirected_to dinosaur_url(@dinosaur)
  end

  test "should destroy dinosaur" do
    assert_difference('Dinosaur.count', -1) do
      delete dinosaur_url(@dinosaur)
    end

    assert_redirected_to dinosaurs_url
  end
end

require 'rspec'
require_relative 'spec_helper'
require_relative 'mocks'

describe Player do
  before(:each) do
    @player = Player.new()
    @scenario = Scenario.new()
    @scenario.warrior_health = 20
    @scenario.direction_of_stairs = :backward
    @scenario.forward = EmptySpace.new()
    @scenario.backward = EmptySpace.new()
    @scenario.left = EmptySpace.new()
    @scenario.right = EmptySpace.new()
    @scenario.filled_spaces = []
    @scenario.spaces_toward_ticking = []
    @scenario.targeted_enemy_direction = nil
    @scenario.targeted_captive_direction = nil
    @scenario.direction_of_ticking = nil
    @scenario.closest_captive_distance = nil
  end

  it "rests when health is less than min clear health and no enemies are near by by level is not clear" do
    @scenario.warrior_health = 4
    @scenario.direction_of_stairs = :forward
    @scenario.backward = WallSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    @scenario.filled_spaces = [SludgeSpace.new()]
    action = @player.decide(@scenario)
    action.type.should eq('rest!')
  end

  it "walks when health is greater than or equal to min clear health and no enemies are near by by level is not clear" do
    @scenario.warrior_health = 19
    @scenario.direction_of_stairs = :forward
    @scenario.backward = WallSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    @scenario.filled_spaces = [SludgeSpace.new()]
    @scenario.targeted_enemy_direction = :forward
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:forward)
  end

  it "detonates when health is less than full and an enemy is near by" do
    @scenario.warrior_health = 19
    @scenario.direction_of_stairs = :forward
    @scenario.forward = SludgeSpace.new()
    @scenario.backward = WallSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    @scenario.filled_spaces = [SludgeSpace.new()]
    @scenario.targeted_enemy_direction = :forward
    action = @player.decide(@scenario)
    action.type.should eq('detonate!')
    action.option.should eq(:forward)
  end

  it "walks toward the door if health is full with no obstacles and level is clear" do
    @scenario.direction_of_stairs = :right
    @scenario.backward = WallSpace.new()
    @scenario.left = WallSpace.new()
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:right)
  end

  it "walks toward enemy if not a neighbor and health is full and no ticking" do
    @scenario.filled_spaces = [SludgeSpace.new()]
    @scenario.targeted_enemy_direction = :right
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:right)
  end

  it "moves toward the door if health is full and navigate obstacles and level is clear" do
    @scenario.direction_of_stairs = :right
    @scenario.backward = WallSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should_not eq(:right)
  end

  it "binds enemies when enemy neighbors are > 1" do
    @scenario.direction_of_stairs = :forward
    @scenario.forward = SludgeSpace.new()
    @scenario.backward = WallSpace.new()
    @scenario.left = SludgeSpace.new()
    @scenario.right = WallSpace.new()
    @scenario.filled_spaces = [SludgeSpace.new(), SludgeSpace.new()]
    action = @player.decide(@scenario)
    action.type.should eq('bind!')
  end

  it "always binds Thick Sludge first" do
    @scenario.left = SludgeSpace.new()
    @scenario.right = ThickSludgeSpace.new()
    @scenario.filled_spaces = [ThickSludgeSpace.new(), SludgeSpace.new()]
    action = @player.decide(@scenario)
    action.type.should eq('bind!')
    action.option.should eq(:right)
  end

  it "doesn't bind an already bound enemy" do
    @scenario.backward = SludgeSpace.new()
    @scenario.left = SludgeSpace.new()
    @scenario.right = ThickSludgeSpace.new(bound = true)
    @scenario.filled_spaces = [ThickSludgeSpace.new(bound = true), SludgeSpace.new(), SludgeSpace.new()]
    action = @player.decide(@scenario)
    action.type.should eq('bind!')
    action.option.should eq(:left)
  end

  it "walks toward ticking captives before fighting and path clear" do
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new()]
    @scenario.direction_of_ticking = :right
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:right)
  end

  it "fights enemies if obstructing path toward ticking captives" do
    @scenario.right = SludgeSpace.new()
    @scenario.backward = WallSpace.new()
    @scenario.left = EmptySpace.new()
    @scenario.forward = WallSpace.new()
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new()]
    @scenario.direction_of_ticking = :right
    action = @player.decide(@scenario)
    action.type.should eq('attack!')
    action.option.should eq(:right)
  end

  it "rescues neighboring ticking captives before fighting" do
    @scenario.right = CaptiveSpace.new(ticking = true)
    @scenario.left = SludgeSpace.new()
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new()]
    @scenario.direction_of_ticking = :right
    action = @player.decide(@scenario)
    action.type.should eq('rescue!')
    action.option.should eq(:right)
  end

  it "detonates bomb if next to two enemies in a row blocking a ticking captive" do
    @scenario.right = SludgeSpace.new()
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new(), SludgeSpace.new()]
    @scenario.direction_of_ticking = :right
    @scenario.spaces_toward_ticking = [SludgeSpace.new(), SludgeSpace.new(), EmptySpace.new()]
    action = @player.decide(@scenario)
    action.type.should eq('detonate!')
    action.option.should eq(:right)
  end

  it "rests if neighboring enemies are bound and health is less than 10 and unbound enemies block ticking captive" do
    @scenario.warrior_health = 9
    @scenario.right = SludgeSpace.new(bound = true)
    @scenario.left = SludgeSpace.new(bound = true)
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new(), SludgeSpace.new(), SludgeSpace.new()]
    @scenario.direction_of_ticking = :forward
    @scenario.spaces_toward_ticking = [EmptySpace.new(), SludgeSpace.new(), CaptiveSpace.new(ticking = true)]
    action = @player.decide(@scenario)
    action.type.should eq('rest!')
  end

  it "walks if neighboring enemies are bound and health is less than 10 and unbound enemies exist but do not block ticking captive" do
    @scenario.warrior_health = 9
    @scenario.right = SludgeSpace.new(bound = true)
    @scenario.left = SludgeSpace.new(bound = true)
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new(), SludgeSpace.new(), SludgeSpace.new()]
    @scenario.direction_of_ticking = :forward
    @scenario.spaces_toward_ticking = [EmptySpace.new(), EmptySpace.new(), CaptiveSpace.new(ticking = true)]
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:forward)
  end

  it "attacks enemy blocking ticking captive even if enemy is bound" do
    @scenario.warrior_health = 19
    @scenario.right = SludgeSpace.new(bound = true)
    @scenario.left = SludgeSpace.new()
    @scenario.direction_of_ticking = :right
    @scenario.filled_spaces = [CaptiveSpace.new(ticking = true), SludgeSpace.new()]
    action = @player.decide(@scenario)
    action.type.should eq('attack!')
    action.option.should eq(:right)
  end

  it "detonates the unbound neighbor enemy before bound neighbor enemy" do
    @scenario.right = SludgeSpace.new(bound = true)
    @scenario.left = SludgeSpace.new(bound = true)
    @scenario.backward = SludgeSpace.new()
    @scenario.targeted_enemy_direction = :backward
    action = @player.decide(@scenario)
    action.type.should eq('detonate!')
    action.option.should eq(:backward)
  end

  it "rests when energy < min clear health and neighbor enemies bound and no ticking" do
    @scenario.warrior_health = 4
    @scenario.right = SludgeSpace.new(bound = true)
    @scenario.filled_spaces = [SludgeSpace.new(bound = true)]
    action = @player.decide(@scenario)
    action.type.should eq('rest!')
  end

  it "walk toward captive when level is clear except for captive" do
    @scenario.filled_spaces = [CaptiveSpace.new()]
    @scenario.targeted_captive_direction = :left
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:left)

    @scenario.warrior_health = 1
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:left)
  end

  it "rescues captive if they're a neighbor and level is clear" do
    @scenario.right = CaptiveSpace.new()
    @scenario.targeted_captive_direction = :right
    action = @player.decide(@scenario)
    action.type.should eq('rescue!')
    action.option.should eq(:right)
  end

  it "doesn't go down the stairs if the level is not clear" do
    @scenario.filled_spaces = [SludgeSpace.new()]
    @scenario.targeted_enemy_direction = :forward
    @scenario.forward = StairsSpace.new()
    action = @player.decide(@scenario)
    action.type.should eq ('walk!')
    action.option.should_not eq(:forward)
  end

  it "walks toward the stairs (and doesn't rest) if health is less than full and the level is clear" do
    @scenario.warrior_health = 1
    @scenario.direction_of_stairs = :left
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should eq(:left)
  end

  it "walks toward the stairs (and doesn't rest) if health is less than full and the level is clear but path blocked" do
    @scenario.warrior_health = 1
    @scenario.direction_of_stairs = :left
    @scenario.left = WallSpace.new()
    action = @player.decide(@scenario)
    action.type.should eq('walk!')
    action.option.should_not eq(:left)
  end

  it "detonates an unbound neighbor enemy if health is full and no ticking" do
    @scenario.left = ThickSludgeSpace.new(bound = true)
    @scenario.targeted_enemy_direction = :left
    action = @player.decide(@scenario)
    action.type.should eq('detonate!')
    action.option.should eq(:left)
  end

  it "rescues neighbor captive when no enemies exist and health is less than full" do
    @scenario.filled_spaces = [CaptiveSpace.new()]
    @scenario.backward = CaptiveSpace.new()
    @scenario.targeted_captive_direction = :backward
    @scenario.warrior_health = 1
    action = @player.decide(@scenario)
    action.type.should eq('rescue!')
    action.option.should eq(:backward)
  end

  it "detonates an unbound enemy neighbor if closet captive is out of blast radius and health > min clear health" do
    @scenario.warrior_health = 18
    @scenario.filled_spaces = [CaptiveSpace.new(), ThickSludgeSpace.new()]
    @scenario.forward = ThickSludgeSpace.new()
    @scenario.closest_captive_distance = 3
    @scenario.targeted_enemy_direction = :forward
    action = @player.decide(@scenario)
    action.type.should eq('detonate!')
    action.option.should eq(:forward)
  end

  it "detonates a bound enemy neighbor if closet captive is out of blast radius and health > min clear health" do
    @scenario.warrior_health = 18
    @scenario.filled_spaces = [CaptiveSpace.new(), ThickSludgeSpace.new(bound = true)]
    @scenario.forward = ThickSludgeSpace.new(bound = true)
    @scenario.closest_captive_distance = 3
    @scenario.targeted_enemy_direction = :forward
    action = @player.decide(@scenario)
    action.type.should eq('detonate!')
    action.option.should eq(:forward)
  end
end

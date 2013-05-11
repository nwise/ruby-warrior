require 'rspec'
require_relative 'spec_helper'
require_relative 'mocks'

describe Scenario do
  before(:each) do
    @scenario = Scenario.new()
    @scenario.warrior_health = 20
    @scenario.direction_of_stairs = :backward
    @scenario.forward = EmptySpace.new()
    @scenario.backward = EmptySpace.new()
    @scenario.left = EmptySpace.new()
    @scenario.right = EmptySpace.new()
    @scenario.filled_spaces = []
    @scenario.spaces_toward_ticking = []
  end

  it "returns all neighbor spaces with no filter" do
    @scenario.forward = WallSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    empty_spaces = @scenario.neighbors()
    empty_spaces.count.should eq 4
    empty_spaces.should include :forward
    empty_spaces.should include :backward
    empty_spaces.should include :left
    empty_spaces.should include :right
  end

  it "returns empty neighbor spaces with empty? filter" do
    @scenario.forward = WallSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    empty_spaces = @scenario.neighbors('empty?')
    empty_spaces.count.should eq 1
    empty_spaces.should include :backward
  end

  it "returns enemy neighbor spaces with enemy? filter" do
    @scenario.forward = SludgeSpace.new()
    @scenario.left = WallSpace.new()
    @scenario.right = WallSpace.new()
    empty_spaces = @scenario.neighbors('enemy?')
    empty_spaces.count.should eq 1
    empty_spaces.should include :forward
  end

  it "returns enemy neighbor spaces by type" do
    @scenario.right = SludgeSpace.new()
    @scenario.neighbors('Sludge').count.should eq(1)
  end

  it "returns min clear health for a level with one sludge" do
    @scenario.filled_spaces = [SludgeSpace.new()]
    @scenario.min_clear_health.should eq(9)
  end

  it "returns min clear health for a level with one thick sludge" do
    @scenario.filled_spaces = [ThickSludgeSpace.new()]
    @scenario.min_clear_health.should eq(15)
  end

  it "returns min clear health for a level with many various sludges" do
    @scenario.filled_spaces = [ThickSludgeSpace.new(), SludgeSpace.new()]
    @scenario.min_clear_health.should eq(20)
  end
end

require_relative 'action'

lesson "Rest when health is less than full and no enemies near by and level is not cleared of enemies yet" do
  conditions ->(scenario) {
    if scenario.warrior_health < scenario.min_clear_health and scenario.neighbors('enemy?').count == 0 and scenario.any_enemies?
      return 0.4
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('rest!')
  }
end

lesson "Attack when at least one unbound enemy is near by and no captives ticking" do
  conditions ->(scenario) {
    if scenario.neighbors('enemy?').count > 0 and scenario.all_spaces('ticking?').count == 0
      return 0.4
      else
      return 0.0
    end
  }
  response ->(scenario) {
    if not scenario.any_unbound_enemy_neighbor_direction.nil?
      direction = scenario.any_unbound_enemy_neighbor_direction
    else
      direction = scenario.any_enemy_neighbor_direction
    end
    return Action.new('attack!', direction)
  }
end

lesson "Attack bound enemy if health is full and all neighbor enemies are bound and no ticking" do
  conditions ->(scenario) {
    if scenario.warrior_health >= scenario.min_clear_health and scenario.neighbors('enemy?').count ==  0 and not scenario.any_enemy_neighbor_direction.nil? and scenario.all_spaces('ticking?').count == 0
      return 0.4
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('attack!', scenario.any_enemy_neighbor_direction)
  }
end

lesson "Walk toward the stairs if level is cleared and path clear" do
  conditions ->(scenario) {
    if scenario.all_spaces.count == 0 and scenario.neighbors('empty?').include?(scenario.direction_of_stairs)
      return 0.2
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('walk!', scenario.direction_of_stairs)
  }
end

lesson "Walk toward the stairs if level is cleared and path blocked" do
  conditions ->(scenario) {
    if scenario.all_spaces.count == 0 and not scenario.neighbors('empty?').include?(scenario.direction_of_stairs)
      return 0.1
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('walk!', scenario.neighbors('empty?').sample)
  }
end

lesson "Walks to open space if path is blocked" do
  conditions ->(scenario) {
    open_spaces = scenario.neighbors("empty?")
    enemy_spaces = scenario.neighbors('enemy?')
    if not open_spaces.include?(scenario.direction_of_stairs) and not enemy_spaces.include?(scenario.direction_of_stairs)
      return 0.1
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('walk!', scenario.neighbors("empty?")[0])
  }
end

lesson "Bind when more than one enemy is near and bind Thick Sludge first" do
  conditions ->(scenario) {
    if scenario.neighbors('enemy?').count > 1
      return 1.0
    else
      return 0.0
    end
  }
  response ->(scenario) {
    thick_sludge_neighbors = scenario.neighbors('Thick Sludge')
    if thick_sludge_neighbors.count == 1 and scenario.neighbors('enemy?').include?(thick_sludge_neighbors[0])
      bind_direction = thick_sludge_neighbors[0]
    else
      bind_direction = scenario.neighbors('enemy?')[0]
    end
    return Action.new('bind!', bind_direction)
  }
end

lesson "Walk toward ticking captives before fighting and path clear" do
  conditions ->(scenario) {
    if scenario.all_spaces('ticking?').count > 0 and scenario.neighbors('empty?').include?(scenario.direction_of_ticking)
      return 0.9
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('walk!', scenario.direction_of_ticking)
  }
end

lesson "Attack enemies blocking path to ticking captives" do
  conditions ->(scenario) {
    if scenario.all_spaces('ticking?').count > 0 and not scenario.neighbors('empty?').include?(scenario.direction_of_ticking) and scenario.neighbors('ticking?').count == 0 and scenario.neighbors('enemy?').include?(scenario.direction_of_ticking)
      return 0.9
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('attack!', scenario.direction_of_ticking)
  }
end

lesson "Rescue neighboring ticking captives before fighting" do
  conditions ->(scenario) {
    if scenario.neighbors('ticking?').count > 0
      return 1.0
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('rescue!', scenario.direction_of_ticking)
  }
end

lesson "Detonate bomb if two enemies are blocking a ticking captive" do
  conditions ->(scenario) {
    if scenario.all_spaces('ticking?').count > 0 and
        scenario.spaces_toward_ticking.count > 0 and
        scenario.spaces_toward_ticking[0].enemy? and
        scenario.spaces_toward_ticking[1].enemy?
      return 0.95
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('detonate!', scenario.direction_of_ticking)
  }
end

lesson "Rest if neighboring enemies are bound and health < 10 and unbound enemies block ticking captive" do
  conditions ->(scenario) {
    if scenario.warrior_health < 10 and scenario.all_spaces('ticking?').count > 0 and scenario.neighbors('enemy?').count == 0 and (scenario.all_spaces('Sludge').count + scenario.all_spaces('Thick Sludge').count) > (scenario.neighbors('Sludge').count + scenario.neighbors('Thick Sludge').count) and (scenario.spaces_toward_ticking[0].enemy? or scenario.spaces_toward_ticking[1].enemy? or scenario.spaces_toward_ticking[2].enemy?)
      return 1.0
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('rest!')
  }
end

lesson "Attack enemy blocking ticking captive even if enemy is bound" do
  conditions ->(scenario) {
    if scenario.all_spaces('ticking?').count > 0 and scenario.neighbor(scenario.direction_of_ticking).to_s == 'Sludge' or scenario.neighbor(scenario.direction_of_ticking).to_s == 'Thick Sludge'
      return 0.9
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('attack!', scenario.direction_of_ticking)
  }
end

lesson "Walk toward enemy if not a neighbor and health > min clear health and no ticking and path clear" do
  conditions ->(scenario) {
    if scenario.any_enemies? and scenario.warrior_health >= scenario.min_clear_health and scenario.direction_of_ticking.nil? and scenario.neighbors('empty?').include?(scenario.targeted_enemy_direction) and not scenario.neighbors('stairs?').include?(scenario.targeted_enemy_direction)
      return 0.7
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('walk!', scenario.targeted_enemy_direction)
  }
end

lesson "Walk toward enemy if not a neighbor and health is full and no ticking and path is blocked" do
  conditions ->(scenario) {
    if (scenario.all_spaces('Sludge').count > 0 or scenario.all_spaces('Thick Sludge').count > 0) and scenario.warrior_health >= scenario.min_clear_health and scenario.direction_of_ticking.nil? and scenario.neighbors('empty?').include?(scenario.targeted_enemy_direction) and scenario.neighbors('stairs?').include?(scenario.targeted_enemy_direction)
      return 0.8
    else
      return 0.0
    end
  }
  response ->(scenario) {
    empty_spaces = scenario.neighbors('empty?')
    empty_spaces.delete(scenario.targeted_enemy_direction)
    return Action.new('walk!', empty_spaces.sample)
  }
end

lesson "Rest when health is less than full and neighbor enemies bound and no ticking" do
  conditions ->(scenario) {
    if scenario.warrior_health < scenario.min_clear_health and scenario.neighbors('enemy?').count == 0 and scenario.direction_of_ticking.nil? and not scenario.any_enemy_neighbor_direction.nil?
      return 0.75
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('rest!')
  }
end

lesson "Walk toward captive when level is clear except for captive" do
  conditions ->(scenario) {
    if not scenario.targeted_captive_direction.nil? and scenario.targeted_enemy_direction.nil? and scenario.neighbors('Captive').count == 0
      return 0.8
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('walk!', scenario.targeted_captive_direction)
  }
end

lesson "Rescue captive if they're a neighbor" do
  conditions ->(scenario) {
    if scenario.neighbors('Captive').count > 0
      return 0.4
    else
      return 0.0
    end
  }
  response ->(scenario) {
    return Action.new('rescue!', scenario.targeted_captive_direction)
  }

lesson "Detonate an enemy neighbor if captives are out of blast radius and health is full plus some" do
    conditions ->(scenario) {
      if scenario.warrior_health >= scenario.min_clear_health + 2 and not scenario.any_enemy_neighbor_direction.nil? and (scenario.closest_captive_distance.nil? or scenario.closest_captive_distance > 2)
        return 0.8
      else
        return 0.0
      end
    }
    response ->(scenario) {
      return Action.new('detonate!', scenario.targeted_enemy_direction)
    }
  end
end

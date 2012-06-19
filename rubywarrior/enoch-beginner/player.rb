class Player
  attr_reader :warrior

  def initialize()
    @low_health_threshold = 11
    @walk_direction = :forward
    @last_attacked_by = :none
    @health = 20
    @should_wait = false
    @attacked_last_round = false
    @rescued_last_round = false
    @shot_last_round = false
  end

  def play_turn(warrior)
    @warrior = warrior


    if can_rescue?
      @should_wait = true
      @rescued_last_round = true
      take_action(:rescue!, @rescue_direction)
      return
    elsif low_health? and @shot_last_round
      @shot_last_round = false
      take_action(:walk!, :backward)
      return
    elsif should_wait? == true
      @should_wait = false
      return
    elsif ranged_enemy?
      @shot_last_round = true
      take_action(:shoot!, :forward)
      return
    elsif facing_enemy?
      take_action(:attack!, :forward)
      return
    elsif ranged_enemy? and low_health?
      puts 'ranged && low health'
      take_action(:walk!, :backward)
      return
    #elsif low_health?
    #  puts 'low_healh'
    #  take_action(:walk!, :backward)
    #  return
    elsif hurt?
      take_action(:rest!)
      return
    else
      take_action(:walk!, :forward)
      return
    end

  end

  def can_rescue?
    @rescue_direction = :forward
    can_rescue = false
    [:forward, :backward].each do |direction|
      if warrior.feel(direction).captive?
        @rescue_direction = direction
        can_rescue = true
      end
    end
    return can_rescue
  end

  def ranged_enemy?
    been_attacked? and !facing_enemy?
  end

  def facing_enemy?
    warrior.feel.enemy?
  end

  def been_attacked?
    @health.to_i > warrior.health
  end

  def hurt?
    warrior.health < 20
  end

  def low_health?
    @warrior.health <= @low_health_threshold
  end

  def should_pivot?
    warrior.feel.wall?
  end

  def should_wait?
    @should_wait
  end

  def health_lost
    @health - @warrior.health
  end

  def last_attacked_by
    case health_lost
    when 9
      :wizard
    when 3
      :archer
    when 3
      :sludge
    else
      :none
    end
  end

  def did_wait?
    @did_wait
  end

  def take_action(action, params=:forward)
    @health = warrior.health
    @last_action = action
    case action
    when :walk!
      if should_pivot?
        warrior.pivot!
      else
        warrior.walk!(params)
      end
    when :attack!
      warrior.attack!(params)
    when :rest!
      warrior.rest!
    when :shoot!
      warrior.shoot!(params)
    when :rescue!
      warrior.rescue!(params)
    when :bind!
      @did_wait = true
      warrior.bind!
    else
      raise "No action taken"
    end
  end

end

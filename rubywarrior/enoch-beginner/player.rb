class Player
  attr_reader :warrior

  def initialize()
    @low_health_threshold = 7
  end

  def play_turn(warrior)
    @warrior = warrior
    if can_rescue?
      take_action(:rescue!, @rescue_direction)
      return
    elsif danger_ahead? && low_health?
      take_action(:walk!, :backward)
      return
    elsif danger_ahead?
      take_action(:walk!, :forward)
      return
    elsif facing_enemy?
      take_action(:attack!, :forward)
      return
    elsif hurt?
      take_action(:rest!)
      return
    else
      take_action(:walk!)
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

  def danger_ahead?
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

  def take_action(action, params=:forward)
    @health = warrior.health
    @last_action = action
    case action
    when :walk!
      warrior.walk!(params)
    when :attack!
      warrior.attack!(params)
    when :rest!
      warrior.rest!
    when :shoot!
      warrior.shoot!(params)
    when :rescue!
      warrior.rescue!(params)
    else
      raise "No action taken"
    end
  end

end

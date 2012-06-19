class Player
  attr_reader :warrior

  def initialize()
    @low_health_threshold = 12
    @walk_direction = :forward
    @last_attacked_by = :none
    @health = 20
    @did_wait = false
  end

  def play_turn(warrior)
    @warrior = warrior

    if can_rescue?
      take_action(:rescue!, @rescue_direction)
      return
    elsif ranged_enemy?
      take_action(:shoot!, :forward)
      return
    elsif facing_enemy?
      take_action(:attack!, :forward)
      return
    elsif ranged_enemy? and low_health?
      take_action(:walk!, :backward)
      return
    elsif low_health?
      take_action(:walk!, :backward)
      return
    elsif hurt?
      take_action(:rest!)
      return
    elsif did_wait?
      take_action(:walk!, @walk_direction)
      return
    else
      @did_wait = true
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

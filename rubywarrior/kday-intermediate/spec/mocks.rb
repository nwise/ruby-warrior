class Space
  def empty?
    true
  end

  def enemy?
    false
  end

  def ticking?
    false
  end

  def stairs?
    false
  end

  def to_s
    'Empty'
  end
end

class EmptySpace < Space
end

class WallSpace < Space
  def empty?
    false
  end

  def to_s
    'Wall'
  end
end

class SludgeSpace < Space
  attr_accessor :bound

  def initialize(bound = false)
    self.bound = bound
  end

  def empty?
    false
  end

  def enemy?
    return ! self.bound
  end

  def to_s
    'Sludge'
  end
end

class ThickSludgeSpace < Space
  attr_accessor :bound

  def initialize(bound = false)
    self.bound = bound
  end

  def empty?
    false
  end

  def enemy?
    return ! self.bound
  end

  def to_s
    'Thick Sludge'
  end
end

class CaptiveSpace < Space
  attr_accessor :ticking

  def initialize(ticking = false)
    self.ticking = ticking
  end

  def ticking?
    return self.ticking
  end

  def to_s
    'Captive'
  end
end

class StairsSpace < Space
  def to_s
    'Stairs'
  end

  def stairs?
    true
  end
end

class Action
  attr_accessor :type, :option

  def initialize(type = nil, option = nil)
    self.type = type
    self.option = option
  end

  def perform(warrior)
    if not self.type.nil?
      if self.option.nil?
        warrior.send(self.type)
      else
        warrior.send(self.type, self.option)
      end
    end
  end
end

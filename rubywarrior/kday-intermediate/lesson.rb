class Lesson
  attr_accessor :description, :stored_conditions, :action

  def initialize(description)
    self.description = description
  end

  def conditions(proc)
    self.stored_conditions = proc
  end

  def applicability(scenario)
    self.stored_conditions.call(scenario)
  end

  def response(proc)
    self.action = proc
  end

  def respond(scenario)
    self.action.call(scenario)
  end
end

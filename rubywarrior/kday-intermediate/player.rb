require_relative 'scenario'
require_relative 'knowledge'
require_relative 'helpers'
require_relative 'action'

class Player
  def play_turn(warrior)
    self.decide(Scenario.build(warrior)).perform(warrior)
  end

  def decide(scenario)
    sorted_lessons = Knowledge.all.sort_by { |lesson| -lesson.applicability(scenario) }
    most_applicable_lesson = sorted_lessons.first

    if most_applicable_lesson.applicability(scenario) < 0.01
     # Fall-back in case no lessons are applicable
      return Action.new('rest!')
    else
      print_decision(sorted_lessons, scenario)
      return most_applicable_lesson.respond(scenario)
    end
  end
end

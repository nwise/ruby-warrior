require_relative 'lesson'

class Knowledge
  @@lessons = []

  def self.all()
   return @@lessons
  end

  def self.add(lesson)
    @@lessons.push(lesson)
  end
end

def lesson(description, &block)
  new_lesson = Lesson.new(description)
  new_lesson.instance_eval &block
  Knowledge.add(new_lesson)
end

require_relative 'lessons_learned'

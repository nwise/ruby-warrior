def print_decision(lessons, scenario)
  limit = 3
  counter = 1
  lessons.each do |lesson|
    applicability = lesson.applicability(scenario)
    if counter > 3 or applicability < 0.01
      break
    end
    print "\n"
    if counter == 1
      print "*"
    else
      print " "
    end
    chart = number_to_bar_chart(applicability)
    print " " + chart + " " + lesson.description + " (" + applicability.to_s + ")"
    counter += 1
  end
  print "\n\n"
end

def number_to_bar_chart(applicability)
  chart = ""
  bars = (applicability * 10).floor
  for i in 0...bars
    chart += "|"
  end
  if bars < 10
    spaces = 10 - bars
    for i in 0...spaces
      chart += " "
    end
  end
  return chart
end

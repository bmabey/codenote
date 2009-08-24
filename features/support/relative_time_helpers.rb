# Orginal code by Chris Flipse: http://groups.google.com/group/cukes/browse_thread/thread/7718d65600e4fa84/255bcb25475046b9?lnk=gst&q=relative#255bcb25475046b9
#
#  Example usage in steps:
#
#  Given a document posted today
#  Given a document posted 2 months, 5 days ago
#  Given my last login was 3 hours ago
#  Given a task due 1 week from now


module RelativeTimeHelpers

  def interpret_time(time)
    return nil if time.blank?
    return time if time.kind_of?(Time) or time.kind_of?(Date)
    named_time(time) || time_by_regex(time) || Time.parse(time)
  end

  def named_time(time)
    case time.downcase
    when "today" : Date.today
    when "now" : Time.now
    when "tomorrow" : Date.tomorrow
    when "yesterday" : Date.yesterday
    else nil
    end
  end

  def time_by_regex(time)
    directional_regex = /(ago|from now)$/
    time_regex = /(\d+) (minute|hour|day|week|month|year)s?/i

    direction= time.scan(directional_regex).flatten
    shifts = time.scan(time_regex)

    return nil if direction.empty? or shifts.empty?

    result = Time.now
    backward = (direction.first == "ago")
    shifts.each do |count, unit|
      adjustment = count.to_i.send(unit)
      result = backward ? (result - adjustment) : (result + adjustment)
    end

    result
  end

end

World(RelativeTimeHelpers)

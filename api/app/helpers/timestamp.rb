module Timestamp
  TIMES = [:seconds, :minutes, :hours, :days, :weeks, :months, :years, :range]

  METHODS = [
    {
      method: :utc,
      argument: nil
    },
    {
      method: :iso8601,
      argument: nil
    }
  ]

  def method_hash(method, arg=nil)
    {
      method: method,
      argument: arg
    }
  end

  def now
    Time.now
  end

  def convert_time_to_iso(time=now, operations=METHODS)
    operations.reduce(time) do |a, e|
      e[:argument].nil? ? a.send(e[:method]) : a.send(e[:method], e[:argument])
    end
  end

  def past_time(methods, this_moment=now)
    current = convert_time_to_iso(this_moment)
    past = convert_time_to_iso(this_moment, methods + METHODS)

    {
      from: past,
      until: current
    }
  end

  def past_seconds(seconds)
    past_time([method_hash(:since, -seconds)])
  end

  def past_minutes(minutes)
    past_seconds(minutes * 60)
  end

  def past_hours(hours)
    past_minutes(hours * 60)
  end

  def past_1h
    past_hours(1)
  end

  def past_24h
    past_time([:yesterday])
  end

  def past_days(days)
    past_hours(24 * days)
  end

  def past_week
    past_time([method_hash(:prev_week)])
  end

  def past_weeks(weeks)
    past_time((1..weeks).to_a.map {|e| method_hash(:prev_week)})
  end

  def past_month
    past_time([:prev_month])
  end

  def past_months(months)
    past_time((1..months).to_a.map {|e| method_hash(:prev_month)})
  end

  def past_year
    past_time([:prev_year])
  end

  def past_years(years)
    past_time((1..years).to_a.map {|e| method_hash(:prev_year)})
  end

  def past_(_)
    nil
  end

  def invoke(time_method)
    method(time_method[:method]).call(time_method[:arg])
  end

  def obtain_time_param(parameters)
    (parameters.keys & TIMES)[0]
  end

  def convert_time_to_method(parameters)
    time = (parameters.keys & TIMES)[0]
    {
      method: ('past_' + time.to_s).to_sym,
      arg: parameters[time].to_i
    }
  end
end
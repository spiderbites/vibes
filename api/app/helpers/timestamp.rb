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

  def past_seconds(seconds, since=now)
    past_time([method_hash(:since, -seconds)], since)
  end

  def past_minutes(minutes, since=now)
    past_seconds(minutes * 60, since)
  end

  def past_hours(hours, since=now)
    past_minutes(hours * 60, since)
  end

  def past_1h(since=now)
    past_hours(1, since)
  end

  def past_24h(since=now)
    past_time([:yesterday], since)
  end

  def past_days(days, since=now)
    past_hours(24 * days, since)
  end

  def past_week(since=now)
    past_time([method_hash(:prev_week)], since)
  end

  def past_weeks(weeks, since=now)
    past_time((1..weeks).to_a.map {|e| method_hash(:prev_week)}, since)
  end

  def past_month(since=now)
    past_time([:prev_month], since)
  end

  def past_months(months, since=now)
    past_time((1..months).to_a.map {|e| method_hash(:prev_month)}, since)
  end

  def past_year(since=now)
    past_time([:prev_year], since)
  end

  def past_years(years, since=now)
    past_time((1..years).to_a.map {|e| method_hash(:prev_year)}, since)
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
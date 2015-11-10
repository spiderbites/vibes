module WatsonTwitterApiHelper
  TIMES = [:seconds, :minutes, :hours, :days, :weeks, :months, :years, :range]
  FORMAT = [
     "posted:2015-10-01,2015-11-05",
     "sentiment:positive",
     "sentiment:negative",
     "sentiment:neutral",
     "#ibm",
     'bio_location:"New York"',
     'country_code:us',
     'followers_count:500,1000',
     'friends_count:30,5000',
     'has:children',
     'is:married',
     'point_radius:[41.128611 -73.707778 5.0mi]'
   ]

  def time_restriction?(parameters)
    (parameters.keys & TIMES).length > 0
  end

  def convert_time_to_method(parameters)
    time = (parameters.keys & TIMES)[0]
    {
      method: ('past_' + time.to_s).to_sym,
      arg: parameters[time].to_i
    }
  end

  def q(term)
    term
  end

  def time_format(time)
    if time
      "posted:#{time[:from]},#{time[:until]}"
    else
      ""
    end
  end

  def locations(loc)
    "bio_location:#{loc}"
  end

  def sentiment(senti)
    "sentiment:#{senti}"
  end

  def size_format(size)
    size ||= 500
    "&size=#{size}"
  end
end
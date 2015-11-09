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

  # def order_by_gender(data)
  #   genders = {
  #     :male => [],
  #     :female => [],
  #     :unknown => [],
  #     :"" => []
  #   }
  #   r = data.reduce(genders) do |a, e|
  #     a[e[:gender].downcase.to_sym] << e
  #     a
  #   end
  #   r
  # end

  # def order_by_sentiment(data)
  #   sentiments = {
  #     :positive => [],
  #     :negative => [],
  #     :neutral => [],
  #     :ambivalent => [],
  #     :"" => []
  #   }
  #   data.reduce(sentiments) do |a, e|
  #     a[e[:sentiment].downcase.to_sym] << e
  #     a
  #   end
  # end

  def order_by_gender
    {
      :male => [],
      :female => [],
      :unknown => [],
      :"" => []
    }
  end

  def order_by_sentiment
    {
      :positive => [],
      :negative => [],
      :neutral => [],
      :ambivalent => [],
      :"" => []
    }
  end

  def order_by_(data)
    data
  end

  def slice_up(data, slices)
    if data.length == 0
      data.keys.map {|e| e.each_slice(slices).to_a }
    else
      puts data
      data.each_slice(slices).to_a
    end
  end
end
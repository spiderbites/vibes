module WatsonTwitterApiHelper
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

  def order_by_gender
    {
      :male => [],
      :female => [],
      :unknown => [],
      :"non_existent_key_gender" => []
    }
  end

  def order_by_sentiment
    {
      :positive => [],
      :negative => [],
      :neutral => []
    }
  end
end
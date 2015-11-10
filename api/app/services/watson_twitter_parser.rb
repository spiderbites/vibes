class WatsonTwitterParser
  include WatsonTwitterApiHelper

  attr_accessor :meta_data

  def initialize(unrefined_data, order_by, slices)
    @unrefined_data = sort(unrefined_data)
    @order_by = order_by
    @data = method(('order_by_' + @order_by.to_s).to_sym).call()
    @slice_tracker = SliceTracker.new(slices, @data.keys)
    @tweets = []
    set_meta_data
    parse
    refine
  end

  def sort(data)
    data['tweets'].sort! {|x,y| a = (x['message']['postedTime'] rescue '999999999999999999999999'); b = (y['message']['postedTime'] rescue '999999999999999999999999'); b <=> a}
    data
  end

  def extract(unit)
    e = unit
    gender = (e['cde']['author']['gender'] rescue "non_existent_key_gender").to_s
    sentiment = (e['cde']['content']['sentiment']['polarity'] rescue "").to_s

    {
      gender: (gender == "" ? "non_existent_key_gender" : gender),
      geo: (e['message']['gnip']['profileLocations'][0]['geo']['coordinates'] rescue nil),
      sentiment: classify_sentiment(sentiment.downcase),
      time: (e['message']['postedTime'] rescue nil),
      link: (e['message']['link'] rescue nil),
      text: (e['message']['body'] rescue nil),
      username: (e['message']['actor']['preferredUsername'] rescue nil),
    }
  end

  def set_meta_data
    @meta_data = {
      next: @unrefined_data['related']['next']['href'].split('?q=')[1],
      quantity: @unrefined_data['search']['results'].to_i,
      from: @unrefined_data['related']['next']['href'].split('&')
              .select { |href_portion| href_portion.include?('from=') }[0]
              .split('=')[1]
              .to_i
    }
  end

  # def add(ordering, data)
  #   if @slice_tracker.send(ordering) == 0
  #     @data[ordering] << [data]
  #   else
  #     @data[ordering].last << data
  #   end
  # end

  def add(ordering, data)
    @data[ordering] << data
    @tweets << data
  end

  def parse
    @unrefined_data['tweets'].map do |e|
      data = extract(e)
      ordering = data[@order_by].downcase.to_sym
      add(ordering, data)
    end
  end

  def refine
    intervals = create_hourly_time_slices(1, 10)
    @data.keys.each do |k|
      data = (0..9).map { |_| 0 }
      @data[k].each do |e|
        i = intervals.find_index { |ar| ar[0] <= e[:time] && e[:time] < ar[1] }
        i = i.nil? ? 0 : i
        data[i] += 1
      end
      @data[k] = data
    end
    @refined = {
      time_labels: intervals.map { |e| e[0].split('T')[1] },
      stats: @data,
      tweets: @tweets,
      map: @tweets.reduce([]) do |a, e|
        sentiment = e[:sentiment].downcase
        sentiment = sentiment == "non_existent_key_sentiment" ? "neutral" : sentiment
        if !e[:geo].nil?
          a << (e[:geo] << sentiment)
        end
        a
      end
    }
  end

  def refined_data
    @refined
  end

  private
    def create_hourly_time_slices(hours, slices)
      time = Time.now
      slices_per_hour = 60 / (slices / hours)
      timings = (0..slices).map { |e| time.since(-60 * (slices_per_hour * e)).utc.iso8601 }.reverse
      intervals = timings.zip timings[1..-1]
      intervals.pop
      intervals
    end

    def classify_sentiment(sentiment)
      if sentiment == "" || sentiment == 'ambivalent'
        'neutral'
      else
        sentiment
      end
    end
end
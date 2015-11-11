class WatsonTwitterParser
  include WatsonTwitterApiHelper

  attr_accessor :meta_data

  def initialize(unrefined_data, config)
    @unrefined_data = unrefined_data
    @data = order_by_sentiment
    @config = config
    @tweets = []
    # set_meta_data
    parse
  end

  def data
    @tweets
  end

  private
    def order_by_sentiment
      {
        :positive => [],
        :negative => [],
        :neutral => []
      }
    end

    def classify_sentiment(sentiment)
      if sentiment == 'ambivalent'
        'neutral'
      else
        sentiment
      end
    end

    def extract(unit)
      e = unit
      gender = (e['cde']['author']['gender'] rescue "unknown").to_s
      sentiment = (e['cde']['content']['sentiment']['polarity'] rescue "neutral").to_s

      {
        gender: gender.downcase,
        geo: (e['message']['gnip']['profileLocations'][0]['geo']['coordinates'] rescue nil),
        sentiment: classify_sentiment(sentiment.downcase),
        time: (e['message']['postedTime'] rescue nil),
        link: (e['message']['link'] rescue nil),
        text: (e['message']['body'] rescue nil),
        username: (e['message']['actor']['preferredUsername'] rescue nil),
      }
    end

    def add(ordering, data)
      @data[ordering] << data
      @tweets << data
    end

    def parse
      @unrefined_data['tweets'].map do |e|
        data = extract(e)
        ordering = data[:sentiment].downcase.to_sym
        add(ordering, data)
      end
    end
end
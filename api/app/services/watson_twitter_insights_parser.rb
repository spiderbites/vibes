class WatsonTwitterInsightsParser

  attr_accessor :meta_data

  def initialize(unrefined_data, query)
    @query = query
    @unrefined_data = unrefined_data
    @tweets = []
    set_meta_data
    parse
  end

  def data
    @tweets
  end

  private

    def classify_sentiment(sentiment)
      (sentiment == 'ambivalent') ? 'neutral' : sentiment
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

    def add(data)
      @tweets << data
    end

    def parse
      @unrefined_data['tweets'].map do |tweet|
        data = extract(tweet)
        add(data)
      end
    end

    def set_meta_data
      @meta_data = {
        current_url: @query,
        next_url: @unrefined_data['related']['next']['href'].split('?q=')[1],
        total: @unrefined_data['search']['results'].to_i,
        next_from: @unrefined_data['related']['next']['href'].split('&')
                .select { |href_portion| href_portion.include?('from=') }[0]
                .split('=')[1]
                .to_i
      }
    end
end
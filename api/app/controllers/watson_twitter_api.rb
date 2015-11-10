module StatesCities
  def states
    JSON.parse(File.read('states.json'))
  end

  def cities
    JSON.parse(File.read('cities.json'))
  end
end

class WatsonTwitterParser
  include WatsonTwitterApiHelper
  attr_accessor :meta_data

  def initialize(unrefined_data, order_by, slices)
    @unrefined_data = sort(unrefined_data)
    @order_by = order_by
    @data = method(('order_by_' + @order_by.to_s).to_sym).call()
    @slice_tracker = SliceTracker.new(slices, @data.keys)

    set_meta_data
    parse
  end

  def sort(data)
    data['tweets'].sort! {|x,y| a = (x['message']['postedTime'] rescue '999999999999999999999999'); b = (y['message']['postedTime'] rescue '999999999999999999999999'); b <=> a}
    data
  end

  def extract(unit)
    e = unit
    gender = (e['cde']['author']['gender'] rescue "non_existent_key_gender").to_s
    sentiment = (e['cde']['content']['sentiment']['polarity'] rescue "non_existent_key_sentiment").to_s

    {
      gender: (gender == "" ? "non_existent_key_gender" : gender),
      location1: (e['cde']['author']['location'] rescue nil),
      location2: (e['message']['actor']['location'] rescue nil),
      location3: (e['message']['object']['actor']['loaction'] rescue nil),
      geo: (e['message']['gnip']['profileLocations'][0]['geo']['coordinates'] rescue nil),
      parentHood: (e['cde']['author']['isParent'] rescue nil),
      maritalStatus: (e['cde']['author']['isMarried'] rescue nil),
      sentiment: (sentiment == "" ? "non_existent_key_sentiment" : sentiment),
      time: (e['message']['postedTime'] rescue nil),
      link: (e['message']['link'] rescue nil),
      text: (e['message']['body'] rescue nil),
      username: (e['message']['actor']['preferredUsername'] rescue nil),
      retweets: (e['message']['retweetCount'] rescue nil),
      favoritesCount: (e['message']['favoritesCount'] rescue nil),
      hashTags: (e['message']['twitter_entities']['hastags'] rescue nil),
      userMentions: (e['message']['twitter_entities']['userMentions'] rescue nil),
      symbols: (e['message']['twitter_entities']['symbols'] rescue nil),
      twitterLanguage: (e['message']['twitter_entities']['twitter_lang'] rescue nil)
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

  def add(ordering, data)
    if @slice_tracker.send(ordering) == 0
      @data[ordering] << [data]
    else
      @data[ordering].last << data
    end
  end

  def parse
    @unrefined_data['tweets'].map do |e|
      data = extract(e)
      ordering = data[@order_by].downcase.to_sym
      add(ordering, data)
    end
  end

  def refined_data
    @data
  end
end

class WatsonTwitterApi
  include HTTParty
  include WatsonTwitterApiHelper
  include Timestamp
  include StatesCities
  base_uri 'https://cdeservice.mybluemix.net/api/v1'
  @@responses = []
  @@counter = 0
  @@username = ENV['username2']
  @@password = ENV['password2']
  @@sentiments = ['positive', 'negative', 'neutral', 'ambivalent'].map {|e| "sentiment:" + e }
  @@auth = {
    basic_auth: {
      username: @@username,
      password: @@password
    }
  }
  QUERRYING_PARAMS = [
    :q,
    :sentiment,
    :locations,
    :bio_lang,
    :country_code,
    :followers_count,
    :friends_count,
    :twitterHandle,
    :children,
    :married,
    :verrified,
    :lang,
    :listed_count,
    :point_radius,
    :statuses_count,
    :time_zone
  ]
  def create_query(parameters, changes)
    has_changed = changes == {} || [:changed].reduce(true) {|a, e| (changes[e] && changes[e].length > 1) && a } ||
    [:ommitted].reduce(true) {|a, e| (changes[e] && changes[e].length > 1) && a } ||
    [:extra].reduce(true) {|a, e| (changes[e] && changes[e].length > 0) && a }

    if has_changed
      r = QUERRYING_PARAMS.reduce("") do |a,e|
        if parameters[e]
          a + ' ' + method(e).call(parameters[e])
        else
          a
        end
      end + ' ' + time_format(invoke(convert_time_to_method(parameters)))
      URI.encode(r)
    else
      changes[:ommitted][:next_call]
    end
  end

  def initialize(parameters, changes)
    @order_by = parameters[:order_by].to_sym
    @slices = (parameters[:in_slices_of] || 48).to_i

    @query = create_query(parameters, changes) +
             size_format(parameters[:by_chunks_of])
  end

  def get
    query = @query
    response = self.class.get("/messages/search?q=#{query}", @@auth)
    parser = WatsonTwitterParser.new(response, @order_by, @slices)
    [{
      data: parser.refined_data
    }.merge(parser.meta_data), parser.meta_data[:next] ]
  end

  def search
    response = self.class.get("/messages/search?q=#{@query}", @@auth)
    @@responses << response
    process_response(response) ? @@responses : search
  end

  def count
    self.class.get("/messages/count?q=#{@query}", @@auth)
  end

  def process_response(response)
    @following_stats = response['related']['next']['href'].split('?q=')[1]
    total = response['search']['results'].to_i
    from = response['related']['next']['href'].split('&').select {|e| e.include?('from=') }[0].split('=')[1].to_i
    puts response
    puts
    puts total, from
    @query = @following_stats
    @@counter += 1

    total == from
  end

  def search1(term)
    query = URI.encode(term)
    watsonApi = WatsonTwitterApi.new
    response = watsonApi.count(query + '&size=500')
  end

  def tweet_scrape(e)
    {
      time: (e['message']['postedTime'] rescue nil),
      link: (e['message']['link'] rescue nil),
      text: (e['message']['body'] rescue nil),
      username: (e['message']['actor']['preferredUsername'] rescue nil),
      retweets: (e['message']['retweetCount'] rescue nil),
      favoritesCount: (e['message']['favoritesCount'] rescue nil),
      hashTags: (e['message']['twitter_entities']['hastags'] rescue nil)
    }
  end

  def author_scrape(e)
    {
      gender: (e['cde']['author']['gender'] rescue nil),
      location1: (e['cde']['author']['location'] rescue nil),
      location2: (e['message']['actor']['location'] rescue nil),
      location3: (e['message']['object']['actor']['loaction'] rescue nil),
      geo: (e['message']['gnip']['profileLocations'][0]['geo']['coordinates'] rescue nil),
      parentHood: (e['cde']['author']['isParent'] rescue nil),
      maritalStatus: (e['cde']['author']['isMarried'] rescue nil),
    }
  end
end

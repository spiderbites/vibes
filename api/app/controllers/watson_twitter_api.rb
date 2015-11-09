module StatesCities
  def states
    JSON.parse(File.read('states.json'))
  end

  def cities
    JSON.parse(File.read('cities.json'))
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
    # @term = parameters[:q]
    # time = invoke(convert_time_to_method(parameters))
    # @time = posted_format(time)
    # @place = location_format(parameters[:locations])
    # @size = size_format(500)
    # query = [@term, @time, @place].reduce {|a, e| a + ' ' + e }
    # @query = URI.encode(query)
    # @cities = cities
    puts parameters
    puts changes
    @query = create_query(parameters, changes) + size_format(parameters[:by_chunks_of])
    puts @query
  end

  def test
    query = @query
    response = self.class.get("/messages/search?q=#{query}", @@auth)
    following_stats = response['related']['next']['href'].split('?q=')[1]
    total = response['search']['results'].to_i
    from = response['related']['next']['href'].split('&').select {|e| e.include?('from=') }[0].split('=')[1].to_i
    ["Empty", following_stats]
  end

  def get
    query = @query
    response = self.class.get("/messages/search?q=#{query}", @@auth)
    following_stats = response['related']['next']['href'].split('?q=')[1]
    total = response['search']['results'].to_i
    from = response['related']['next']['href'].split('&').select {|e| e.include?('from=') }[0].split('=')[1].to_i
    next_calls = {
      following_stats: following_stats,
      total: total,
      from: from
    }
    [{
      place: (@place.split(':')[1] if @place),
      quantity: response['search']['results'],
      data: scrape(response),
    }, following_stats ]
  end

  def get_sentiments
   next_calls = []
   [ @@sentiments.map do |e|
      query = @query + URI.encode(' ' + e)
      response1 = self.class.get("/messages/count?q=#{query}", @@auth)
      response2 = self.class.get("/messages/search?q=#{query}", @@auth)
      following_stats = response2['related']['next']['href'].split('?q=')[1]
      total = response2['search']['results'].to_i
      from = response2['related']['next']['href'].split('&').select {|e| e.include?('from=') }[0].split('=')[1].to_i
      next_calls << {
        result: e.split(':')[1],
        following_stats: following_stats,
        total: total,
        from: from
      }

      {
        place: @place.split(':')[1],
        result: e.split(':')[1],
        quantity: response1['search']['results'],
        data: scrape(response2),
      }
    end, next_calls]
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

  def scrape(response)
    r = response['tweets'].map do |e|
      {
        gender: (e['cde']['author']['gender'] rescue nil),
        location1: (e['cde']['author']['location'] rescue nil),
        location2: (e['message']['actor']['location'] rescue nil),
        location3: (e['message']['object']['actor']['loaction'] rescue nil),
        geo: (e['message']['gnip']['profileLocations'][0]['geo']['coordinates'] rescue nil),
        parentHood: (e['cde']['author']['isParent'] rescue nil),
        maritalStatus: (e['cde']['author']['isMarried'] rescue nil),
        sentiment: (e['cde']['content']['sentiment']['polarity'] rescue nil),
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
    r
  end
end

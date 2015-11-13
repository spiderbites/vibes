class WatsonTwitterApi
  include HTTParty
  include WatsonTwitterApiHelper
  include Timestamp

  base_uri 'https://cdeservice.mybluemix.net/api/v1'

  @@username = ENV['username2']
  @@password = ENV['password2']
  @@auth = {
    basic_auth: {
      username: @@username,
      password: @@password
    }
  }

  def initialize(url, parameters, changes)
    @time = time_format(invoke(convert_time_to_method(parameters)))
    @q = parameters[:q]
    @location = parameters[:locations]
    @from = "&from=#{parameters[:from]}"
    @changes = changes

    time_param = obtain_time_param(parameters)
    @query = url.empty? ? (@changes.empty? ? create_query(parameters) : @changes) : URI.encode(url)
    @config = {
      time: [time_param, parameters[time_param]],
      slices: (parameters[:in_slices_of] || 48).to_i
    }
  end

  def create_query(parameters)
    reconstruct_query(parameters) + size_format(parameters[:by_chunks_of])
  end

  def get
    query = @query + @from
    response = self.class.get(SEARCH + "#{query}", @@auth)
    parser = WatsonTwitterParser.new(response, @config)
    {
      meta_data: parser.meta_data.merge({current_url: @query + @from}),
      data: parser.data
    }
  end

  private
    SEARCH = "/messages/search?q="
    COUNT = "/messages/count?q="
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

    def has_query_changed?(changes)
      changes == {} ||
      (changes[:changed].length > 1) ||
      (changes[:ommitted].length > 1) ||
      (changes[:extra].length > 0)
    end

    def reconstruct_query(parameters)
      r = QUERRYING_PARAMS.reduce("") do |a,e|
        parameters[e] ? a + ' ' + method(e).call(parameters[e]) : a
      end + ' ' + @time
      URI.encode(r)
    end
end
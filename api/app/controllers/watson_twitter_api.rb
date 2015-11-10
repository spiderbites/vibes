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
    if has_query_changed?(changes)
      reconstruct_query(parameters)
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

  private
    def has_query_changed?(changes)
      changes == {} ||
      (changes[:changed].length > 1) ||
      (changes[:ommitted].length > 1) ||
      (changes[:extra].length > 0)
    end

    def reconstruct_query(parameters)
      r = QUERRYING_PARAMS.reduce("") do |a,e|
        parameters[e] ? a + ' ' + method(e).call(parameters[e]) : a
      end + ' ' + time_format(invoke(convert_time_to_method(parameters)))
      URI.encode(r)
    end
end
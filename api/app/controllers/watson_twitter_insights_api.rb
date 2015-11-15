class WatsonTwitterInsightsApi
  include HTTParty
  base_uri 'https://cdeservice.mybluemix.net/api/v1'

  @@username = ENV['username2']
  @@password = ENV['password2']
  @@auth = {
    basic_auth: {
      username: @@username,
      password: @@password
    }
  }

  def initialize(query)
    @query = query
  end

  def get
    response = self.class.get(SEARCH + "#{@query}", @@auth)
    parser = WatsonTwitterInsightsParser.new(response, @query)
    {
      meta_data: parser.meta_data,
      data: parser.data
    }
  end

  private
    SEARCH = "/messages/search?"
    COUNT = "/messages/count?"

end
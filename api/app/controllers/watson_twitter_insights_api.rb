class WatsonTwitterInsightsApi
  include HTTParty

  base_uri 'https://cdeservice.mybluemix.net/api/v1'

  MAXTRIES = 15
  TIMEOUTDURATION = 60

  @@username = ENV['username2']
  @@password = ENV['password2']
  @@auth = {
    basic_auth: {
      username: @@username,
      password: @@password
    },
    timeout: TIMEOUTDURATION
  }

  def initialize(query)
    @query = query
  end

  def get
    response = http_response_wrapped_in_exception_handling(MAXTRIES)

    begin
      if response[:error]
        response
      else
        parser = WatsonTwitterInsightsParser.new(response, @query)
        {
          meta_data: parser.meta_data,
          data: parser.data
        }
      end
    rescue Exception => e
      # An anamoly occured which needs further inspection as to its cause.
      # Here is more detail from /resque/failed
      #     Exception: TypeError
      #     Error: no implicit conversion of Symbol into Integer
      #     /Users/Coder/.rvm/gems/ruby-2.1.5/gems/httparty-0.13.7/lib/httparty/response.rb:67:in `[]'
      #     /Users/Coder/.rvm/gems/ruby-2.1.5/gems/httparty-0.13.7/lib/httparty/response.rb:67:in `method_missing'
      #     /Users/Coder/lighthouse/final-project/latest/vibes_old/api/app/controllers/watson_twitter_insights_api.rb:26:in `get'
      #     /Users/Coder/lighthouse/final-project/latest/vibes_old/api/app/workers/background.rb:25:in `perform'
      binding.pry
      puts generate_error_response(e)
    end
  end

  private
    SEARCH = "/messages/search?"
    COUNT = "/messages/count?"

    def generate_error_response(error)
      {
        error: {
          origin: self.to_s,
          class: error.class.to_s,
          msg: error.to_s,
          cause: error && error.cause && error.cause.to_s || nil,
          number_of_tries: MAXTRIES,
          timeout_duration_in_sec: TIMEOUTDURATION
        },
        query: SEARCH + @query
      }
    end

    def debug_heading(error_class, n)
      "-------------------#{n}-#{error_class}----#{SEARCH + @query}---"
    end

    def manage_exception(e, n)
      heading = debug_heading(e.class.to_s, n)

      response = generate_error_response(e)
      DebugHelper.output_debug_info(response, heading)

      (n > 0)? http_response_wrapped_in_exception_handling(n-1) : response
    end

    def http_response_wrapped_in_exception_handling(n)

      begin
        response = self.class.get(SEARCH + "#{@query}", @@auth)
      rescue Net::ReadTimeout => e
        response = manage_exception(e, n)
      rescue Exception => e
        response = manage_exception(e, n)
      end

      response
    end

end
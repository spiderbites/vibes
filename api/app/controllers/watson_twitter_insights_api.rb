class WatsonTwitterInsightsApi
  include HTTParty

  base_uri 'https://cdeservice.mybluemix.net/api/v1'

  MAXTRIES = 5
  TIMEOUTDURATION = 0.2

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

    if response[:error]
      response
    else
      parser = WatsonTwitterInsightsParser.new(response, @query)
      {
        meta_data: parser.meta_data,
        data: parser.data
      }
    end
  end

  private
    SEARCH = "/messages/search?"
    COUNT = "/messages/count?"

    def generate_error_response(error)
      {
        error: {
          class: error.class.to_s,
          msg: error.to_s,
          cause: error && error.cause && error.cause.to_s || nil,
          number_of_tries: MAXTRIES,
          timeout_duration_in_sec: TIMEOUTDURATION
        },
        query: SEARCH + @query
      }
    end

    def debug_helper(error_msg, n)
      info = "-------------------#{n}-Net::ReadTimeout----#{SEARCH + @query}---"
      Resque.logger.info(info)
      puts info
      Resque.logger.info(error_msg)
      puts error_msg
    end

    def http_response_wrapped_in_exception_handling(n)
      begin
        response = self.class.get(SEARCH + "#{@query}", @@auth)

      rescue Net::ReadTimeout => e

        response = generate_error_response(e)
        debug_helper(response, n)

        if n == 0
          response
        else
          response = http_response_wrapped_in_exception_handling(n-1)
        end

      rescue Exception => e
        response = generate_error_response(e)
        debug_helper(response, n)
      end
      response
    end

end
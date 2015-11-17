class Background

  PAUSEBETWEENAPICALLS = 4

  @queue = :watson_twitter_api_queue

  def self.output_header(url, config)
    DebugHelper.output_data("")
    DebugHelper.output_data("---------START JOB")
    DebugHelper.output_data("-------------#{url}, #{config}")
  end

  def self.output_body(next_url, meta)
    DebugHelper.output_data("------------------#{URI.decode(next_url)}")
    DebugHelper.output_data("---------------------#{meta}")
  end

  def self.perform(url, config)
    output_header(url, config)

    meta = nil
    next_url = ''
    while (!meta || (meta[:from] < meta[:quantity])) do
      watsonApi = WatsonTwitterInsightsApi.new(url)
      results = watsonApi.get

      if results[:error]
        exit
      else
        save_to_db(results)
        meta = results[:meta_data]
        next_url = meta[:next]

        output_body(next_url, meta)

        sleep PAUSEBETWEENAPICALLS

        url = next_url
      end
    end
  end

  def self.save_to_db(data)
    url = URI.decode(data[:meta_data][:current_url].split('&from=')[0])
    Tweet.create data[:data].map { |e| e.merge({url: url}) }
  end
end
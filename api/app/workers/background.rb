class Background
  FAILEDJOBSFILE = 'failed_jobs.log'
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
    while (!meta || (meta[:next_from] < meta[:total])) do
      watsonApi = WatsonTwitterInsightsApi.new(url)
      results = watsonApi.get

      if results[:error]
        log_failed_job(url)
        exit
      else
        save_to_db(results)
        meta = results[:meta_data]
        next_url = meta[:next_url]

        output_body(next_url, meta)

        sleep PAUSEBETWEENAPICALLS

        url = 'q=' + next_url
      end
    end
  end

  def self.save_to_db(data)
    url = URI.decode(data[:meta_data][:current_url].split('&from=')[0])
    Tweet.create data[:data].map { |e| e.merge({url: url}) }
  end

  def self.log_failed_job(url)
    term = url.split('posted:')[0]
    range = url.split('posted:')[1].split('&from')[0]
    from = url.split('&from=')[1].split('&')[0]

    File.open(FAILEDJOBSFILE, 'a') do |file|
      file.puts "#{url}|#{term}|#{range}|#{from}"
    end
  end
end
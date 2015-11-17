class Background

  @queue = :watson_twitter_api_queue
  @@batches = []

  def self.convert_string_hash_to_sym_hash(hash)
    hash.keys.reduce({}) {|a,e| a[e.to_sym] = hash[e]; a}
  end

  def self.perform(url, config)
    Resque.logger.info("")
    Resque.logger.info "---------START JOB"
    Resque.logger.info("-------------#{url}, #{config}")
    batches = []
    meta = nil
    next_url = ''
    while (!meta || (meta[:from] < meta[:quantity])) do
      watsonApi = WatsonTwitterInsightsApi.new(url, {}, next_url)
      url = ''
      results = watsonApi.get
      save_to_db([results])
      # batches << results
      meta = results[:meta_data]
      next_url = meta[:next]
      Resque.logger.info("------------------#{URI.decode(next_url)}")
      Resque.logger.info("---------------------#{meta}")
      sleep 4
    end
  end

  def self.save_to_db(batches)
    batches.each do |batch|
      url = URI.decode(batch[:meta_data][:current_url].split('&from=')[0])
      batch[:data].each { |e| Tweet.create e.merge({url: url}) }
    end
  end
end
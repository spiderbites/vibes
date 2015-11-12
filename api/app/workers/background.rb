class Background
  @queue = :watson_twitter_api_queue
  @@batches = []

  def self.convert_string_hash_to_sym_hash(hash)
    hash.keys.reduce({}) {|a,e| a[e.to_sym] = hash[e]; a}
  end

  def self.perform(parameters, changes)
    batches = []
    meta = nil
    next_url = ''
    Rails.logger.debug(parameters.inspect)
    while (!meta || (meta[:from] < meta[:quantity])) do
      watsonApi = WatsonTwitterApi.new(convert_string_hash_to_sym_hash(parameters), next_url)

      results = watsonApi.get
      batches << results
      meta = results[:meta_data]
      next_url = meta[:next]
      puts meta
    end
    save_to_db(batches)
  end

  def self.save_to_db(batches)
    batches.each do |batch|
      url = URI.decode(batch[:meta_data][:current_url].split('&from=')[0])
      batch[:data].each { |e| Tweet.create e.merge({url: url}) }
    end
  end


end
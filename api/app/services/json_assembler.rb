require 'JSON'
class JsonAssembler
  attr_reader :json
  def initialize(data, config)
    @data = data
    if @data[:error]
      @json = @data.merge({config: config})
    else
      @config = config
      @json = {}
      generate_meta_data
      assemble
    end
  end

  private
    def generate_meta_data
      if @data[:meta_data]
        @json[:meta_data] = @data[:meta_data]
      else
        @json[:meta_data] = {
          current_url: @config.query,
          next_url: nil,
          total: nil, # Tweet.count_them @config
          next_from: nil
        }
      end
    end

    def assemble
      if @config.route == :immediate
        ActiveRecord::Base.connection.execute("TRUNCATE Caches")
        Cache.create @data[:data]
        data = Cache.statistics_improved @config
      else
        data = Tweet.statistics_improved @config
      end

      @json[:data] = data
      @json[:data][:map] = data[:tweets].select {|tweet| tweet[:geo]}.map do |tweet|
        {
          :geo => JSON.parse(tweet[:geo]),
          :sentiment => tweet[:sentiment]
        }
      end
    end
end
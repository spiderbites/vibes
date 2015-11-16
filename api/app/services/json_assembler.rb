class JsonAssembler
  attr_reader :json
  def initialize(data, config)
    @data = data
    @config = config
    @json = {}
    generate_meta_data
    assemble
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
        data = Cache.statistics @config
      else
        data = Tweet.statistics @config
      end

      @json[:data] = data
      @json[:data][:map] = data[:tweets].map do |tweet|
        {
          :geo => tweet[:geo],
          :sentiment => tweet[:sentiment]
        }
      end
    end
end
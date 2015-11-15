class JsonAssembler
  attr_reader :json
  def initialize(api, stats_config)
    @data = api.get
    @stats_config = stats_config
    @json = {}
    @json[:meta_data] = @data[:meta_data]
    assemble
  end

  private
    def assemble
      ActiveRecord::Base.connection.execute("TRUNCATE Caches")
      Cache.create @data[:data]
      data = Cache.statistics @stats_config

      @json[:data] = data
      @json[:data][:map] = data[:tweets].map do |tweet|
        {
          :geo => tweet[:geo],
          :sentiment => tweet[:sentiment]
        }
      end
    end
end
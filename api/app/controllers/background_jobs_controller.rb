class BackgroundJobsController

  def self.run(config)
    BackgroundJobsController.new(config)
  end

  private

    def initialize(config)
      time_param = config.time.unit
      @config = config
      @time = {
        :type => config.time.unit,
        :quantity => config.time.quantity,
        :format => config.time.stamp,
        :range => "?"
      }
      @term = config.term.contents
      @location = config.location.contents
      construct_query
      dispatchWorkers
    end

    def construct_query
      @query = {
        :term => @term,
        :location => @location,
        :time => @time[:format]
      }
    end

    def dispatchWorkers
      distribution = Tweet.determine_db_api_distribution(@query)
      if distribution[:api].empty?
        # Nothing needs to be done as everything is in the db
      else
        distribution[:api].each do |interval|
          _from = interval[:from].gsub('.000Z', 'Z')
          _until = interval[:until].gsub('.000Z', 'Z')
          url = 'q=' + @query[:term] + ' posted:' +
                  _from + ',' +
                  _until + '&size=500'
          Resque.enqueue(Background, URI.encode(url), @config)
        end
      end
    end
end
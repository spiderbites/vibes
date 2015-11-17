class BackgroundJobsController
  include Timestamp

  def self.run(config)
    BackgroundJobsController.new(config)
  end

  private

    def initialize(config)
      time_param = config.time.unit
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
      @config = {
        :term => @term,
        :location => @location,
        :time => @time[:format]
      }
    end

    def dispatchWorkers
      distribution = Tweet.determine_db_api_distribution(@config)
      if distribution[:api].empty?
        # Nothing needs to be done as everything is in the db
      else
        distribution[:api].each do |interval|
          _from = interval[:from].gsub('.000Z', 'Z')
          _until = interval[:until].gsub('.000Z', 'Z')
          url = @config[:term] + ' posted:' +
                  _from + ',' +
                  _until + '&size=500'
          Resque.enqueue(Background, url, {}, '')
        end
      end
    end
end
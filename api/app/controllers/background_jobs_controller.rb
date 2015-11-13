class BackgroundJobsController
  include Timestamp

  def self.run(query)
    BackgroundJobsController.new(query)
  end

  private

    def initialize(query)
      time_param = obtain_time_param(query)[0]
      if time_param
        time = invoke(convert_time_to_method(query))
        @time = {
          :type => time_param,
          :quantity => query[time_param],
          :format => time_format(time),
          :range => time
        }
      else
        time = invoke(convert_time_to_method({hours: 1}))
        @time = {
          :type => :hours,
          :quantity => 1,
          :format => time_format(time),
          :range => time
        }
      end
      @term = query[:q]
      @location = query[:locations]
      construct_query
      dispatchWorkers
    end

    def construct_query
      @query = {
        :term => @term,
        :location => @location || '',
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
          url = @query[:term] + ' posted:' +
                  _from + ',' +
                  _until + '&size=500'
          Resque.enqueue(Background, url, {}, '')
        end
      end
    end

    def time_format(time)
      if time
        "#{time[:from]},#{time[:until]}"
      else
        ""
      end
    end
end
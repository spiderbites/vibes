class Statistics < ActiveRecord::Base
  self.abstract_class = true
  def self.statistics(config)
    if self.count == 0
      empty_db_result
    else
      # @times = @ordered.map { |e| e.time }.uniq
      @time = {
        :from => config.time.time_format[:from].to_time,
        :until => config.time.time_format[:until].to_time + (config.stats.quantity).minutes
      }
      _from = @time[:from].utc.iso8601.sub('Z', '.000Z')
      _until = @time[:until].utc.iso8601.sub('Z', '.000Z')
      @ordered = self.where("url LIKE '%#{config.term.contents}%' and time <= '#{_until}' and time >= '#{_from}'").order(:time)
      intervals = divide_in_intervals(config.stats)
      calculate(intervals, config.stats)
    end
  end

  def self.determine_db_api_distribution(query)
    @ordered = self.where("url LIKE ? and url LIKE ?", "%#{query[:term]}%", "%#{query[:location]}%").order(:time)
    _from = @ordered.first ? @ordered.first.time : Time.now.utc.iso8601
    _until = @ordered.last ? @ordered.last.time : Time.now.utc.iso8601
    interval_db = {
      :from => _from,
      :until => _until
    }
    distribute_query_over_db_api(interval_db, convert_time_str_to_hash(query[:time]))
  end

  private
    # A query can be in relation to what is present in the database have following possibilities:
    #   Either entire query is present in db
    #   Either portion is present, portion is missing
    #     Either the missing portion is because it is more recent.
    #       In this case the start-point should be that of the interval_query and the end point
    #       should be the starting point of the interval_db
    #     Either the missing portion is because it is more distant.
    #       In this case the start point should be the endpoint of the interval_db and the end point
    #       should be the end point of the interval_query
    #     Either it is on account of both previous reasons.
    #       In this case, two API searches will need to be made according to above two possibilities.
    #   Either entire query is absent from db and this on account of following:
    #     Either this is because the db is completely empty
    #     Either this is because the db is empty with regards to that query
    #       Either this is because the enquired time range does not overlap anything present in the database
    #         In such a case if the enquired range is earlier, then update the db to cover the missing gap
    #       Either this is because there is nothing about the topic present in the database.
    def self.distribute_query_over_db_api(interval_db, interval_query)
      if (interval_db[:from] < interval_query[:from]) &&
        (interval_db[:until] > interval_query[:until])
        {
          db: interval_query,
          api: []
        }
      elsif (interval_db[:from] > interval_query[:from]) &&
            (interval_db[:until] > interval_query[:until])
        {
          db: nil,
          api: [
            {
              :from => interval_query[:from],
              :until => interval_db[:from]
            }
          ]
        }
      # This possibility is highly unlikely to occur in current implementation
      # as every query by standard is from Time.now, thus by definition always
      # more recent than latest db contents.
      elsif (interval_db[:from] < interval_query[:from]) &&
            (interval_db[:until] < interval_query[:until])
        {
          db: nil,
          api: [
            {
              :from => interval_db[:until],
              :until => interval_query[:until]
            }
          ]
        }
      elsif (interval_db[:from] > interval_query[:from]) &&
           (interval_db[:until] < interval_query[:until])
        {
          db: interval_db,
          api: [
            {
              :from => interval_query[:from],
              :until => interval_db[:from]
            },
            {
              :from => interval_db[:until],
              :until => interval_query[:until]
            }
          ]
        }
      # In this case the database is empty as the until points converge.
      else
        {
          db: nil,
          api: [interval_query]
        }
      end
    end

    def self.convert_time_str_to_hash(time)
      begin_end_time = time.split(',')
      {
        :from => begin_end_time[0],
        :until => begin_end_time[1]
      }
    end



    def self.divide_in_intervals(config)
      case config.unit
      when :by_minutes
        create_intervals_by_minutes(config)
      else
        @ordered
      end
    end

    def self.create_intervals_by_minutes(stats_config)
      timings = (@time[:from].to_i..@time[:until].to_i).step((stats_config.quantity).minutes).map{ |t| Time.at(t).utc.iso8601 }
      result = timings.zip timings[1..-1]
      result[1..-2]
    end

    def self.calculate(intervals, stats_config)
      result = ['positive', 'negative', 'neutral'].reduce({}) do |a, e|
        a[e] = intervals.map do |interval|
          @ordered.where("time < '#{interval[1]}' and time >= '#{interval[0]}' and sentiment='#{e}'")
        end.map {|e| e.count}
        a
      end
      result[:timings] = calculate_timings(intervals, stats_config)
      result[:tweets] = @ordered.first(750)
      result
    end

    def self.calculate_timings(intervals, stats_config)
      prev_day = ""
      intervals.map do |interval|
        current_day, current_time = interval[0].split('T')
        if [:by_minutes, :by_hours].include?(stats_config.unit)
          if prev_day != current_day
            prev_day = current_day
            interval[0]
          else
            current_time
          end
        else
          current_day
        end
      end
    end

    def self.empty_db_result
      {
        positive: [],
        negative: [],
        neutral: [],
        tweets: []
      }
    end
end
class Statistics < ActiveRecord::Base
  self.abstract_class = true

  def self.statistics_improved(config)
    db = self.name.downcase + 's'
    sql = {
      :aggregate => "
          SELECT
              date_trunc('minute', time) - (CAST(EXTRACT(MINUTE FROM time) AS integer) % 10) * interval '1 minute' AS intervals,
              sentiment,
              count(*)
          FROM #{db}
          GROUP BY sentiment, intervals
          ORDER BY sentiment, intervals;
        ",
      :min => "SELECT date_trunc('minute', min) - (CAST(EXTRACT(MINUTE from min) AS integer) % 10) * interval '1 minute' as intervals from (SELECT min(time) from #{db}) as m;",
      :max => "SELECT date_trunc('minute', max) - (CAST(EXTRACT(MINUTE from max) AS integer) % 10) * interval '1 minute' as intervals from (SELECT max(time) from #{db}) as m;"
    }

    min = ActiveRecord::Base.connection.execute(sql[:min]).to_a[0]["intervals"]
    max = ActiveRecord::Base.connection.execute(sql[:max]).to_a[0]["intervals"]
    records = ActiveRecord::Base.connection.execute(sql[:aggregate])

    step_unit = :minutes
    @in_steps_of = (10).send(step_unit)

    @time = {
      :from => min.to_time,
      :until => max.to_time
    }

    if (db == 'caches')
      tweets = self.all
    else
      tweets = self.where("url LIKE '%#{config.term.contents}%' and time <= '#{max}' and time >= '#{min}'")
    end

    range = (@time[:from].to_i..@time[:until].to_i)
    timings = range.step(@in_steps_of).map{ |t| Time.at(t).strftime('%Y-%m-%d %H:%M:%S') }
    # results = records.to_a.reduce({:negative => [], :positive => [], :neutral => []}) {|a,e| a[e["sentiment"].to_sym] << [e["intervals"], e["count"]]; a }

    zeros = Array.new(timings.length, 0)

    hash = {
      :negative => Hash[timings.zip zeros],
      :positive => Hash[timings.zip zeros],
      :neutral => Hash[timings.zip zeros]
    }

    results = records.reduce(hash) {|a,e| a[e["sentiment"].to_sym][e["intervals"]] = e["count"].to_i; a}
    {
      :timings => timings,
      :negative => results[:negative].values,
      :positive => results[:positive].values,
      :neutral => results[:neutral].values,
      :tweets => tweets
    }
  end

  def self.statistics(config)
    if self.count == 0
      empty_db_result
    else
      # @times = @ordered.map { |e| e.time }.uniq
      step_unit = config.stats.unit.to_s.sub('by_','').to_sym
      @in_steps_of = (config.stats.quantity).send(step_unit)

      @time = {
        :from => config.time.time_format[:from].to_time,
        :until => config.time.time_format[:until].to_time + @in_steps_of
      }
      _from = @time[:from].utc.iso8601.sub('Z', '.000Z')
      _until = @time[:until].utc.iso8601.sub('Z', '.000Z')
      @ordered = self.where("url LIKE '%#{config.term.contents}%' and time <= '#{_until}' and time >= '#{_from}'").order(:time)
      intervals = divide_in_intervals
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



    def self.divide_in_intervals
      range = (@time[:from].to_i..@time[:until].to_i)
      timings = range.step(@in_steps_of).map{ |t| Time.at(t) }
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
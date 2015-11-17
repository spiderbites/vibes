class Statistics < ActiveRecord::Base
  self.abstract_class = true

  def self.statistics_improved(config)
    @db = self.name.downcase + 's'
    if @db == 'caches'
      constraint = ""
    else
      _from = config.time.time_format[:from].to_time.strftime('%Y-%m-%d %H:%M:%S')
      _until = config.time.time_format[:until].to_time.strftime('%Y-%m-%d %H:%M:%S')
      constraint = "WHERE time <= '#{_until}' and time >= '#{_from}'"
    end

    unit = config.stats.unit.to_s.sub('by_','').to_s
    quantity = config.stats.quantity.to_i
    sql = {
      :aggregate => "
          SELECT
              date_trunc('#{unit}', time) - (CAST(EXTRACT(#{unit} FROM time) AS integer) % #{quantity}) * interval '1 #{unit}' AS intervals,
              sentiment,
              count(*)
          FROM #{@db}
          #{constraint}
          GROUP BY sentiment, intervals
          ORDER BY sentiment, intervals;
        ",
      :min => "SELECT date_trunc('#{unit}', min) - (CAST(EXTRACT(#{unit} from min) AS integer) % #{quantity}) * interval '1 #{unit}' as intervals from (SELECT min(time) from #{@db} #{constraint}) as m;",
      :max => "SELECT date_trunc('#{unit}', max) - (CAST(EXTRACT(#{unit} from max) AS integer) % #{quantity}) * interval '1 #{unit}' as intervals from (SELECT max(time) from #{@db} #{constraint}) as m;"
    }
    @min = ActiveRecord::Base.connection.execute(sql[:min]).to_a[0]["intervals"]
    @max = ActiveRecord::Base.connection.execute(sql[:max]).to_a[0]["intervals"]
    @records = ActiveRecord::Base.connection.execute(sql[:aggregate])
    step_unit = unit.to_sym
    @in_steps_of = (config.stats.quantity).send(step_unit)

    if @min && @max
      @time = {
        :from => @min.to_time,
        :until => @max.to_time
      }
      assemble_results(config)
    else
      empty_db_result
    end
  end

  def self.assemble_results(config)
    if (@db == 'caches')
      tweets = self.all
    else
      term = config.term.to_db_compatible_s
      sql = "url LIKE '%#{term}%' and time <= '#{@max}' and time >= '#{@min}'"
      tweets = self.where(sql)
    end

    range = (@time[:from].to_i..@time[:until].to_i)
    timings = range.step(@in_steps_of).map do |t|
      Time.at(t).strftime('%Y-%m-%d %H:%M:%S')
    end

    # The data assembly below ensures a consistent format as opposed to the other query:
    #     results = @records.to_a.reduce({:negative => [], :positive => [], :neutral => []}) {|a,e| a[e["sentiment"].to_sym] << [e["intervals"], e["count"]]; a }
    # which entails gaps in the data. The approach below is not the most ideal approach as it conflates
    # front-end needs with back-end, but for our purpose it is simply more convenient and only takes about 50 ms extra.
    zeros = Array.new(timings.length, 0)

    acc = {
      :negative => Hash[timings.zip zeros],
      :positive => Hash[timings.zip zeros],
      :neutral => Hash[timings.zip zeros]
    }

    results = @records.reduce(acc) do |a, e|
      a[e["sentiment"].to_sym][e["intervals"]] = e["count"].to_i
      a
    end

    {
      :timings => timings,
      :negative => results[:negative].values,
      :positive => results[:positive].values,
      :neutral => results[:neutral].values,
      :tweets => tweets
    }
  end

  def self.determine_db_api_distribution(query)
    @ordered = self.where("url LIKE ? and url LIKE ?", "%#{query[:term]}%", "%#{query[:location]}%").order(:time)
    _from = @ordered.first ? @ordered.first.time.iso8601 : Time.now.utc.iso8601.to_s
    _until = @ordered.last ? @ordered.last.time.iso8601 : Time.now.utc.iso8601.to_s
    interval_db = {
      :from => _from,
      :until => _until
    }
    distribute_query_over_db_api(interval_db, convert_time_str_to_hash(query[:time]))
  end

  private
    # A query atm primarily consists of term and time range
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
    #     Either this is because the db is empty with regards to that query only
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
      # In this case the database is empty as the `until` points converge.
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

    def self.empty_db_result
      {
        positive: [],
        negative: [],
        neutral: [],
        tweets: []
      }
    end
end
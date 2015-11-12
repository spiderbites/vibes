class Tweet < ActiveRecord::Base
  def self.statistics(unit)
    @ordered = Tweet.order(:time)
    @times = @ordered.map { |e| e.time }.uniq
    @time = {
      :start => @times.first.to_time,
      :end => @times.last.to_time + (unit[:quantity]).minutes
    }
    intervals = divide_in_intervals(unit)
    calculate(intervals)
  end

  private
    def self.divide_in_intervals(unit)
      case unit[:type]
      when :by_minutes
        create_intervals_by_minutes(unit)
      else
        @ordered
      end
    end

    def self.create_intervals_by_minutes(unit)
      timings = (@time[:start].to_i..@time[:end].to_i).step((unit[:quantity]).minutes).map{ |t| Time.at(t).utc.iso8601 }
      result = timings.zip timings[1..-1]
      result[1..-2]
    end

    def self.calculate(intervals)
      result = ['positive', 'negative', 'neutral'].reduce({}) do |a, e|
        a[e] = intervals.map do |e|
          @ordered.where("time < '#{e[1]}' and time >= '#{e[0]}' and sentiment='positive'")
        end.map {|e| e.count}
        a
      end
      result[:intervals] = intervals.map { |e| e[0].split('T')[1] }
      result[:tweets] = @ordered
      result
    end
end


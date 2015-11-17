class PaginationParser
  attr_reader :from, :size

  def initialize(parameters)
    @from = parameters.from.to_i rescue 0
    @size = parameters.size.to_i rescue 500
  end

  def errors
    nil
  end

  def to_s
    "&from=#{@from}&size=#{@size}"
  end
end

class LocationParser
  attr_reader :contents

  def initialize(parameters)
    loc = parameters.location rescue nil
    @contents = loc || ""
  end

  def errors
    nil
  end

  def to_s
    @contents.empty? ? "" : "bio_location:#{@contents}"
  end
end

class StatsParser
  attr_reader :unit, :quantity

  def initialize(parameters)
    @stats = parameters.stats rescue nil
    @unit = (@stats && @stats.split(':')[0].to_sym) || :by_minutes
    @quantity = (@stats && @stats.split(':')[1].to_i) || 6
  end

  def errors
    nil
  end

  def to_s
    ""
  end
end

class TimeParser
  include Timestamp
  attr_reader :time_format, :unit, :quantity, :stamp

  def initialize(parameters)
    @parameters = parameters
    @unit = obtain_time_unit || :hours
    @since = nil
    @quantity = @parameters.send(@unit).to_i rescue 3
    @time_format = time_stamp(@since)
    @stamp = "#{@time_format[:from]},#{@time_format[:until]}"
  end

  def reset_stamp
    @stamp = "#{@time_format[:from]},#{@time_format[:until]}"
  end

  def update_stamp(interval)
    @stamp = "#{interval[:from]},#{interval[:until]}"
  end

  def errors
    (@parameters.public_methods & TIMES).length > 1 ? "At most one time parameter allowed." : nil
  end

  def to_s
    "posted:#{@stamp}"
  end

  private
    def obtain_time_unit
      (@parameters.public_methods & TIMES)[0]
    end

    def time_stamp(since)
      invoke(convert_time_to_method, since)
    end

    def invoke(time_method, since)
      if since
        method(time_method[:method]).call(time_method[:arg], since)
      else
        method(time_method[:method]).call(time_method[:arg])
      end
    end

    def convert_time_to_method
      {
        method: ('past_' + @unit.to_s).to_sym,
        arg: @quantity
      }
    end
end

class TermParser
  attr_reader :contents

  def initialize(parameters)
    @contents = parameters.q.to_s rescue ""
  end

  def errors
    @contents.empty? ? "No search term provided" : nil
  end

  def to_s
    @contents.empty? ? "" : "q=#{@contents}"
  end

  def to_db_compatible_s
    @contents.split.join('+')
  end
end

class ParametersParser
  def initialize(parameters)
    parameters.keys.each do |key|
      instance_variable_set("@#{key}", parameters[key])
    end

    parameters.keys.each do |key|
      self.class.send(:define_method, key.to_s) do
        instance_variable_get("@#{key}")
      end
    end
  end

  def errors?
    !@q
  end

  def errors
    errors? ? "Unable to search as the term-holder `q=` is missing." : nil
  end

  def to_s
    ""
  end
end

class QueryParser
  attr_reader :term, :time, :stats, :location, :query, :route

  def initialize(parameters)
    @parameters = ParametersParser.new(parameters)
    @term = TermParser.new(@parameters)
    @time = TimeParser.new(@parameters)
    @stats = StatsParser.new(@parameters)
    @location = LocationParser.new(@parameters)

    @route = @parameters.action.to_sym
    @pagination = PaginationParser.new(@parameters)

    @@parsers = [@parameters, @term, @time, @stats, @location, @pagination]
    @query = create_a_query
  end

  def create_a_query
    URI.encode(@@parsers.map(&:to_s).select(&:presence).join(' ')).gsub('\u0026',"&")
  end

  def errors?
    @@parsers.reduce(false) { |a, e| e.errors || a }
  end

  def errors
    @@parsers.map(&:errors).select(&:presence)
  end
end
class LocationParser
  attr_reader :location

  def initialize(parameters)
    loc = parameters.location rescue nil
    @location = loc || ""
  end

  def errors
    nil
  end

end

class StatsParser
  UNITS = ['by_minutes', 'by_hours', 'by_days']
  attr_reader :unit, :quantity

  def initialize(parameters)
    @stats = parameters.stats rescue nil
    @unit = (@stats && @stats.split(':')[0]) || 'by_minutes'
    @quantity = (@stats && @stats.split(':')[1].to_i) || 6
  end

  def errors
    nil
  end

end

class TimeParser
  include Timestamp
  attr_reader :time_format, :unit, :quantity

  def initialize(parameters)
    @parameters = parameters
    @unit = obtain_time_unit || :hours
    @since = nil
    @quantity = @parameters.send(@unit).to_i rescue 3
    @time_format = time_stamp(@since)
  end

  def errors
    (@parameters.public_methods & TIMES).length > 1 ? "At most one time parameters allowed." : nil
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
    @contents = parameters.q
  end

  def errors
    @contents.empty? ? "No search term is provided" : nil
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
end

class QueryParser
  attr_reader :time, :stats, :location

  def initialize(parameters)
    @parameters = ParametersParser.new(parameters)
    @term = TermParser.new(@parameters)
    @time = TimeParser.new(@parameters)
    @stats = StatsParser.new(@parameters)
    @location = LocationParser.new(@parameters)

    @@parsers = [@parameters, @term, @time, @stats, @location]
  end

  def errors?
    @@parsers.reduce(false) { |a, e| e.errors || a }
  end

  def errors
    @@parsers.map(&:errors)
  end
end
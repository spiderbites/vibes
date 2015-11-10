module ParameterSanity
    TIMES = [:seconds, :minutes, :hours, :days, :weeks, :months, :years, :range]
    ORDERED_BY = ['gender', 'sentiment', 'location']
    SENTIMENT = ['positive', 'negative', 'neutral', 'ambivalent']
    BASIC_ERROR_MSG = "Restricted to following values:"
    SANITY = {
      :q => lambda { |e| true },
      :order_by => lambda { |e| ORDERED_BY.include?(e) },
      :sentiment => lambda { |e| SENTIMENT.include?(e) },
      :locations => lambda { |e| e =~ /\A(?=[A-z,]+$)[A-z]+(,[A-z]+)*\z/ }
    }
    ERRORS = {
      :order_by => "#{BASIC_ERROR_MSG} #{ORDERED_BY}",
      :sentiment => "#{BASIC_ERROR_MSG} #{SENTIMENT}",
      :locations => "only letters with comma separation if more than one."
    }
    ERRORS.default = "Only numbers allowed."

    SANITY.default = lambda { |e| e.to_s =~ /\A\d+\z/ }

    def sanity_check_passed?(parameters)
      !!parameters.keys.reduce(true) do |a, e|
        SANITY[e.to_sym].call(parameters[e]) && a
      end && ([time_to_be_singular(parameters)].flatten.length == 0)
    end

    def time_to_be_singular(parameters)
      timing_specifications = parameters.keys & TIMES
      if timing_specifications.length > 1
        {
          msg: "Time ambiguity. At most one time specification allowed.",
          actual: timing_specifications.map do |e|
            h = {}
            h[e] = parameters[e]
            h
          end
        }
      else
        []
      end
    end

    def sanity_violations(parameters)
      parameters.keys.select do |e|
        r = SANITY[e.to_sym].call(parameters[e])
        # puts "#{e} | #{SANITY[e.to_sym].call(parameters[e])} => #{r}"
        !r
      end.map do |e|
        h = {}
        h[e] = {
          msg: ERRORS[e],
          actual: parameters[e]
        }
        h
      end + [time_to_be_singular(parameters)].flatten
    end
end
class QueryParser

  def initialize(parameters)
    @parameters = convert_string_hash_to_sym_hash(parameters)
    @timeParser = TimeParser.new(@parameters)
    @statsParser = StatsParser.new(@parameters)
  end

  private
    def convert_string_hash_to_sym_hash(hash)
      hash.keys.reduce({}) {|a,e| a[e.to_sym] = hash[e]; a}
    end
end
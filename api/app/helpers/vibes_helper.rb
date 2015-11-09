module VibesHelper
  def convert_string_hash_to_sym_hash(hash)
    hash.keys.reduce({}) {|a,e| a[e.to_sym] = hash[e]; a}
  end

  def convert_to_hash(arr)
    arr.reduce({}) { |a,e| a[e[0].to_sym] = e[1]; a }
  end

  def determine_changes(h1, h2)
    if h1[:epoch] && (h2[:epoch].to_i - h1[:epoch].to_i < 30)
      extra = h2.to_a - h1.to_a
      ommitted = h1.to_a - h2.to_a
      changed = [extra.select { |e| h1[e[0]] }, ommitted.select { |e| h2[e[0]] }]
      {
        extra: convert_to_hash(extra - changed[0]),
        ommitted: convert_to_hash(ommitted - changed[1]),
        changed: changed.flatten(1).reduce({}) do |a, e|
          if a[e[0]]
            a[e[0]][:old] = e[1]
          else
            a[e[0]] = {new: e[1]}
          end
          a
        end
      }
    else
      {
      }
    end
  end
end
class SliceTracker
  def initialize(slices, categories_to_track)
    @max = slices
    categories_to_track.each do |name|
      instance_variable_set("@#{name}", -1)
    end

    categories_to_track.each do |action|
      self.class.send(:define_method, action.to_s) do
        i = instance_variable_get("@#{action}")
        new_value = (i == @max - 1) ? 0 : i + 1
        instance_variable_set("@#{action}", new_value)
        puts "@#{action} => #{new_value}"
        new_value
      end
    end
  end
end
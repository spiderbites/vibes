class ChangeDataTypeForTime < ActiveRecord::Migration
  def self.up
    remove_column :tweets, :time
    add_column :tweets, :time, :datetime
  end

  def self.down
    remove_column :tweets, :time
    add_column :tweets, :time, :string
  end
end

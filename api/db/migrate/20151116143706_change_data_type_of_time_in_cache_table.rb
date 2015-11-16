class ChangeDataTypeOfTimeInCacheTable < ActiveRecord::Migration
  def self.up
    remove_column :caches, :time
    add_column :caches, :time, :datetime
  end

  def self.down
    remove_column :caches, :time
    add_column :caches, :time, :string
  end
end
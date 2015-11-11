class AddUrlToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :url, :string
  end
end

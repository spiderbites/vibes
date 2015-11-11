class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.text :text
      t.string :link
      t.string :username
      t.string :gender
      t.string :geo
      t.string :sentiment
      t.string :time

      t.timestamps null: false
    end
  end
end

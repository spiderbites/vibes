class CreateCaches < ActiveRecord::Migration
  def change
    create_table :caches do |t|
      t.text :text
      t.string :link
      t.string :username
      t.string :gender
      t.string :geo
      t.string :sentiment
      t.string :time
      t.string :url

      t.timestamps null: false
    end
  end
end

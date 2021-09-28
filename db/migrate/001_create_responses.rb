class CreateResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :responses do |t|
      t.string :initial_status_ids
      t.integer :final_status_id
      t.integer :time_limit
      t.text :note
      t.integer :author_id
      t.boolean :enabled
      t.string :name
      t.string :tracker_ids
      t.string :organization_ids

      t.timestamps null: false
    end
  end
end

class RemoveIsPrivateFromResponse < ActiveRecord::Migration[5.2]
  def change
    remove_column :responses, :is_private, :boolean
  end
end

class AddAssignedToAttributeToResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :responses, :assigned_to_id, :integer
  end
end

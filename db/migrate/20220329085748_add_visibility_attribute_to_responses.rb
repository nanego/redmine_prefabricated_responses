class AddVisibilityAttributeToResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :responses, :visibility, :integer, default: 0
    add_column :responses, :project_id, :integer
  end
end

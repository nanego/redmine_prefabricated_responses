class AddMissingIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :responses, :assigned_to_id, if_not_exists: true
    add_index :responses, :author_id, if_not_exists: true
    add_index :responses, :final_status_id, if_not_exists: true
    add_index :responses, :project_id, if_not_exists: true
    add_index :responses_roles, :role_id, if_not_exists: true
    add_index :responses_roles, [:response_id, :role_id], if_not_exists: true
  end
end

class CreateResponsesRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :responses_roles, :id => false do |t|
      t.column :response_id, :integer, :null => false
      t.column :role_id, :integer, :null => false
    end
  end
end

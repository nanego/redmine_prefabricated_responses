class AddIsPrivateAttributeToResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :responses, :is_private, :boolean, default: true
  end
end

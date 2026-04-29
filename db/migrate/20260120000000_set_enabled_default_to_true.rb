# frozen_string_literal: true

class SetEnabledDefaultToTrue < ActiveRecord::Migration[7.2]
  def change
    change_column_default :responses, :enabled, from: nil, to: true
  end
end

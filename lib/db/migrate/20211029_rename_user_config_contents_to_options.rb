# frozen_string_literal: true

# Creates a table for user configurations
class RenameUserConfigContentsToOptions < ActiveRecord::Migration[6.0]
  def change
    rename_column :user_configs, :contents, :options
  end
end

# frozen_string_literal: true

# Each role can only be registered once per server
class AddUniqueIndexToExtraColorRoles < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL
      DELETE FROM extra_color_roles
      WHERE id NOT IN (
        SELECT MIN(id) FROM extra_color_roles GROUP BY server_id, role_id
      )
    SQL

    add_index :extra_color_roles, %i[server_id role_id], unique: true
  end

  def down
    remove_index :extra_color_roles, %i[server_id role_id]
  end
end

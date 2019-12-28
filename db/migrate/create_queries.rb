class CreateQueries < ActiveRecord::Migration[5.0]
  def change
    create_table :queries do |t|
      t.column :author, :integer
      t.column :text, :string
      t.timestamps
    end
  end
end

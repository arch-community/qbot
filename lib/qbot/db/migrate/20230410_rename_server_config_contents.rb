# frozen_string_literal: true

class RenameServerConfigContents < ActiveRecord::Migration[7.0]
  def change
    change_table :server_configs do |t|
      t.rename :options, :contents

      t.change_null :contents, false, {} # default
      t.change_default :contents, from: nil, to: {}
    end
  end
end

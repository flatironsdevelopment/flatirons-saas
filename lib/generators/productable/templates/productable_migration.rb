# frozen_string_literal: true

class Create<%= table_name.camelize %> < ActiveRecord::Migration[<%= rails_version %>]
  def up
    create_table :<%= table_name %> do |t|
      t.text :description, index: true
      t.string :title, index: true

      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
class CreateTurns < ActiveRecord::Migration
  def change
    create_table :turns do |t|
      t.integer :player_id
      t.integer :pile
      t.integer :beans
      t.belongs_to :game, index: true

      t.timestamps null: false
    end
  end
end

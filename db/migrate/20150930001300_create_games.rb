class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :status
      t.integer :active_player_id
      t.integer :human_player_id
      t.integer :winning_player_id
      t.text :piles

      t.timestamps null: false
    end
  end
end

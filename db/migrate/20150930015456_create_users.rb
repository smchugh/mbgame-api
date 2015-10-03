class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :picture
      t.string :api_token
      t.string :password
      t.datetime :api_token_expiration

      t.timestamps null: false
    end

  end
end

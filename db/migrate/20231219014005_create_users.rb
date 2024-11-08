class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :password_digest
      t.datetime :registered_at, default: -> { "CURRENT_TIMESTAMP" }
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :role
      t.boolean :active, :default => false, :null => false
      t.jsonb :preferences, default: nil
    end
  end
end

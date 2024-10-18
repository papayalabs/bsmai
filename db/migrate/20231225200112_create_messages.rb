class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: true, foreign_key: true
      t.string :role, null: false
      t.string :content_text
      t.datetime :cancelled_at
      t.timestamp :processed_at
      t.integer :index, null: false
      t.integer :version, null: false
      t.boolean :branched, default: false, null: false
      t.integer :branched_from_version

      t.timestamps
    end
    add_index :messages, :updated_at
    add_index :messages, :index
    add_index :messages, :version
    add_index :messages, [:conversation_id, :index, :version], unique: true
  end
end

class CreateAssistants < ActiveRecord::Migration[7.1]
  def change
    create_table :assistants do |t|
      t.references :user, null: true, foreign_key: true
      t.string :model
      t.string :name
      t.string :description
      t.string :instructions
      t.jsonb :tools, null: false, default: []
      t.boolean :images, null: false, default: false
      t.string :api_key
      t.string :api_url
      t.string :api_protocol

      t.timestamps
    end
  end
end

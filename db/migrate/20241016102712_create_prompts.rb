class CreatePrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :prompts do |t|
      t.references :prompt_process, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.string :instructions
      t.integer :priority, :default => 0
      t.timestamps
    end
  end
end

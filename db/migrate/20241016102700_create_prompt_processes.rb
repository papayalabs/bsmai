class CreatePromptProcesses < ActiveRecord::Migration[7.1]
  def change
    create_table :prompt_processes do |t|
      t.string :name
      t.timestamps
    end
  end
end

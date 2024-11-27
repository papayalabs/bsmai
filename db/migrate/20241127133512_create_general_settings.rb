class CreateGeneralSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :general_settings do |t|
      t.string :google_api_key
      t.string :theme_preference
      t.timestamps
    end
  end
end

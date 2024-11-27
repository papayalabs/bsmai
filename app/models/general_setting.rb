class GeneralSetting < ApplicationRecord
  THEMES = ["DARK","LIGHT"]
  validates :theme_preference, inclusion: THEMES
end

class Prompt < ApplicationRecord
  scope :priority, -> { order(priority: :asc) }
  belongs_to :prompt_process
end

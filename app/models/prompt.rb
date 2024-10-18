class Prompt < ApplicationRecord
  scope :priority, -> { order(priority: :asc) }
  belongs_to :prompt_process

  def truncate(string, max)
    string.length > max ? "#{string[0...max]}..." : string
  end
end

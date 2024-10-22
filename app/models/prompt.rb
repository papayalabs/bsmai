class Prompt < ApplicationRecord
  belongs_to :prompt_process
  acts_as_list scope: :prompt_process

  def truncate(string, max)
    string.length > max ? "#{string[0...max]}..." : string
  end
end

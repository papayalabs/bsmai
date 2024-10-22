class PromptProcess < ApplicationRecord
  has_many :prompts, -> { order(position: :asc) }, dependent: :destroy
end
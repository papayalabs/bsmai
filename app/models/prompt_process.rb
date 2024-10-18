class PromptProcess < ApplicationRecord
  has_many :prompts, dependent: :destroy
end
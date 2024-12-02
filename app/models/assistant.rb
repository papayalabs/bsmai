class Assistant < ApplicationRecord
  belongs_to :user, optional: true

  has_many :conversations, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :runs, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_many :messages # TODO: What should happen if an assistant is deleted?

  API_PROTOCOLS = ["ANTHROPIC","GEMINI","OLLAMA","OPEN_AI"]
  validates :api_protocol, inclusion: API_PROTOCOLS

  validates :tools, presence: true, allow_blank: true

  scope :ordered, -> { order(:id) }

  def initials
    return nil if name.blank?

    parts = name.split(/[\- ]/)

    parts[0][0].capitalize +
      parts[1]&.try(:[], 0)&.capitalize.to_s
  end

  def to_s
    name
  end
end

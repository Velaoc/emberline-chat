class Message < ApplicationRecord
  ROLES = %w[user assistant].freeze

  belongs_to :conversation

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true

  def user?
    role == "user"
  end

  def assistant?
    role == "assistant"
  end
end

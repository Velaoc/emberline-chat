class Conversation < ApplicationRecord
  belongs_to :user
  has_many :messages, -> { order(created_at: :asc, id: :asc) }, dependent: :destroy

  validates :title, presence: true, length: { maximum: 120 }

  scope :for_user, ->(user) { where(user: user) }
  scope :ordered, -> { order(updated_at: :desc) }

  # The provider chain sent to the model: all prior turns, oldest first.
  def context_messages
    messages.map { |m| { role: m.role, content: m.content } }
  end
end

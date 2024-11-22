class Announcement < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :announcement_reads, dependent: :destroy
  has_many :readers, through: :announcement_reads, source: :user

  # Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published] }

  # Scopes
  scope :published, -> { where(status: 'published').order(published_at: :desc) }
  scope :recent_published, -> { published.where('published_at > ?', 30.days.ago) }

  # Methods
  def publish!
    update(status: 'published', published_at: Time.current)
  end

  def unpublish!
    update(status: 'draft', published_at: nil)
  end

  def published?
    status == 'published'
  end

  def mark_as_read_by(user)
    announcement_reads.find_or_create_by!(user: user) do |read|
      read.read_at = Time.current
    end
  end

  def read_by?(user)
    announcement_reads.exists?(user_id: user.id)
  end
end

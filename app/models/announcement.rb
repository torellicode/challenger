class Announcement < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :content, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft published] }

  scope :published, -> { where(status: 'published').order(published_at: :desc) }
  scope :recent_published, -> { published.where('published_at > ?', 30.days.ago) }

  def publish!
    update(status: 'published', published_at: Time.current)
  end

  def unpublish!
    update(status: 'draft', published_at: nil)
  end

  def published?
    status == 'published'
  end
end

class AnnouncementsController < ApplicationController
  # Callbacks
  before_action :authenticate_user!, only: [:mark_read, :mark_all_read]

  # Actions
  def index
    @announcements = Announcement.published.order(published_at: :desc)
  end

  def show
    @announcement = if current_user&.admin?
                     Announcement.find(params[:id])
                   else
                     Announcement.published.find(params[:id])
                   end
    
    @announcement.mark_as_read_by(current_user) if current_user
  rescue ActiveRecord::RecordNotFound
    redirect_to announcements_path, alert: "Announcement not found"
  end

  # Methods
  # Mark a single announcement as read
  def mark_read
    @announcement = Announcement.published.find(params[:id])
    @announcement.mark_as_read_by(current_user)
    
    # Force a reload to get fresh counts
    current_user.reload
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: announcements_path) }
      format.turbo_stream
    end
  end

  # Mark all announcements as read
  def mark_all_read
    @announcements = current_user.unread_announcements
    @announcements.each do |announcement|
      announcement.mark_as_read_by(current_user)
    end
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: announcements_path) }
      format.turbo_stream
    end
  end
end

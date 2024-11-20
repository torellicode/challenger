class AnnouncementsController < ApplicationController
  def index
    @announcements = Announcement.published.order(published_at: :desc)
  end

  def show
    @announcement = if current_user&.admin?
                     Announcement.find(params[:id])
                   else
                     Announcement.published.find(params[:id])
                   end
  rescue ActiveRecord::RecordNotFound
    redirect_to announcements_path, alert: "Announcement not found"
  end
end

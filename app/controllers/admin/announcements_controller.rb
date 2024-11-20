module Admin
  class AnnouncementsController < BaseController
    before_action :set_announcement, only: [:edit, :update, :destroy, :publish, :unpublish]

    def index
      @announcements = Announcement.order(created_at: :desc)
    end

    def new
      @announcement = Announcement.new
    end

    def create
      @announcement = current_user.announcements.build(announcement_params)
      
      if @announcement.save
        redirect_to admin_announcements_path, notice: 'Announcement was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @announcement.update(announcement_params)
        redirect_to admin_announcements_path, notice: 'Announcement was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @announcement.destroy
      redirect_to admin_announcements_path, notice: 'Announcement was successfully deleted.'
    end

    def publish
      @announcement.publish!
      redirect_to admin_announcements_path, notice: 'Announcement was published.'
    end

    def unpublish
      @announcement.unpublish!
      redirect_to admin_announcements_path, notice: 'Announcement was unpublished.'
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:title, :content)
    end
  end
end

module AdminAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :require_admin
    layout 'admin'
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end
end

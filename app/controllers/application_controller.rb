class ApplicationController < ActionController::Base
  include Authentication
  include Pundit
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError do
    redirect_to(root_path, alert: "Not allowed.")
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end

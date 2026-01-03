class LandingController < ApplicationController
  allow_unauthenticated_access

  def index
    # Public landing page - no authentication required
  end
end

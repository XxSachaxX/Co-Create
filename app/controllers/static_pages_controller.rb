class StaticPagesController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user

  def terms
  end

  def privacy
  end

  private

  def set_user
    @user = Current.user
  end
end

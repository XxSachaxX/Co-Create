class TagsController < ApplicationController
  skip_before_action :require_authentication, only: [ :index ]

  def index
    @tags = Tag.all

    # Search if query provided
    if params[:query].present?
      @tags = @tags.search(params[:query])
    end

    # Selected tags first, then popular
    selected_ids = Array(params[:selected]).compact_blank
    if selected_ids.any?
      @selected_tags = @tags.where(id: selected_ids)
      @other_tags = @tags.where.not(id: selected_ids).popular.limit(20)
      @tags = @selected_tags + @other_tags
    else
      @tags = @tags.popular.limit(20)
    end

    respond_to do |format|
      format.turbo_stream
      format.json { render json: @tags.as_json(only: [ :id, :name, :projects_count ]) }
    end
  end
end

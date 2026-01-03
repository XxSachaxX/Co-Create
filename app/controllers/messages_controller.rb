class MessagesController < ApplicationController
  before_action :set_project
  before_action :set_user
  before_action :authorize_project_member

  def index
    @messages = @project.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
  end

  def create
    @message = @project.messages.new(user: Current.user, **message_params)

    if @message.save!
      @messages = @project.messages.from_most_recent
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to project_path(@project), notice: I18n.t("messages.controller.message_sent") }
      end
    else
      @messages = @project.messages.from_most_recent
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("messages_section", partial: "messages/messages_section", locals: { project: @project, messages: @messages }) }
        format.html { redirect_to project_path(@project), alert: I18n.t("messages.controller.message_failed") }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_user
    @user = Current.user
  end

  def authorize_project_member
    authorize @project, :member?
  end

  def message_params
    params.require(:message).permit(:content)
  end
end

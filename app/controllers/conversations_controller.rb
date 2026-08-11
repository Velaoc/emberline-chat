class ConversationsController < ApplicationController
  layout "chat"
  before_action :authenticate_user!
  before_action :set_conversation, only: %i[show destroy]

  def index
    @conversations = Conversation.for_user(current_user).ordered
    @conversation = @conversations.first
  end

  def show
    return redirect_to conversations_path, alert: "Conversation not found" unless @conversation

    @conversations = Conversation.for_user(current_user).ordered
    render :index
  end

  def new
    redirect_to conversation_path(Conversation.create!(user: current_user, title: "New chat"))
  end

  def create
    redirect_to conversation_path(Conversation.create!(user: current_user, title: "New chat"))
  end

  def destroy
    @conversation.destroy
    redirect_to root_path, notice: "Conversation deleted"
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find_by(id: params[:id])
  end
end

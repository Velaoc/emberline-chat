class ConversationsController < ApplicationController
  layout "chat"
  before_action :authenticate_user!
  before_action :set_conversation, only: %i[show destroy]

  def index
    @conversations = Conversation.for_user(current_user).ordered
    @conversation = params[:id] ? Conversation.for_user(current_user).find_by(id: params[:id]) : @conversations.first
  end

  def show
    return redirect_to conversations_path, alert: "Conversation not found" unless @conversation

    @conversations = Conversation.for_user(current_user).ordered
    render :index
  end

  def new
    redirect_to conversations_path(Conversation.create!(user: current_user, title: "New chat"))
  end

  def create
    conversation = Conversation.create!(user: current_user, title: "New chat")
    render json: { id: conversation.id, redirect_url: conversation_path(conversation) }, status: :created
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

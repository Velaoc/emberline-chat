module Foundation
  # Emberline Chat landing page for guests. Signed-in users are sent straight
  # to their conversations; the chat app is the product, not a subpage.
  class HomeController < ApplicationController
    def show
      redirect_to conversations_path if user_signed_in?
    end
  end
end

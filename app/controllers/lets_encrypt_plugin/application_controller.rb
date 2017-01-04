module LetsEncryptPlugin
  class ApplicationController < ActionController::Base
    def show
      challenge = Challenge.find_by!(token: params[:token])
      render plain: challenge.content
    end
  end
end

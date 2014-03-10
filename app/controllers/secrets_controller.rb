class SecretsController < ApplicationController
  def new
    @secret = Secret.new
    @recipient = User.find(params[:user_id])
  end

  def create
    @secret = Secret.new(secret_params)
    @secret.author_id = current_user.id
    # @secret.tags.build(tag_params)
    # fail
    if @secret.save
      render :json => @secret
    else
      render :json => @secret.errors.full_messages, :status => 422
    end
    # redirect_to user_url(User.find(params[:secret][:recipient_id]))
  end

  private

  def secret_params
    params.require(:secret).permit(:title, :recipient_id, :tag_ids =>[])
  end
end

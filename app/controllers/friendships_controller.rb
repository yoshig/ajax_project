class FriendshipsController < ApplicationController
  def create
    @friendship = Friendship.new
    @friendship.in_friend_id = current_user.id
    @friendship.out_friend_id = params[:user_id]

    if @friendship.save!
      render :json => @friendship.to_json
    else
      render :json => @friendship.errors
    end
  end

  def destroy
    @friendship = Friendship.find_by(in_friend_id: current_user.id,                                                   out_friend_id: params[:user_id])
    if @friendship
      @friendship.destroy
      render :json => "Friendship destroyed".to_json
    else
      render :json => @friendship.errors
    end
  end

end

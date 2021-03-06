class BotsController < ApplicationController

  def show
    @user = User.find(params[:user_id])
    @bot = Bot.find(params[:id])
    @sentences = @bot.interactions.where(category: "Sentence").order("Sentence")
    @keywords = @bot.interactions.where(category: "Keyword").order("Keyword1")
    @combo = @bot.interactions.where(category: "Combo").order("Keyword1")
  end

  def new
    if signed_in?
      @user = current_user
      @bot = Bot.new
    else
      authenticate_user!
    end
  end

  def create
    @user = current_user
    @bot = @user.bots.new(bot_params)
    if @user.bots.count == 1
      flash[:notice] = "You have reached the limits of BAEs"
      redirect_to user_path(current_user)
    else
      if @bot.save
        @bot.default_vocabulary(params["vocabulary"])
        @bot.send_welcome_message
        flash[:notice] = "BAE created!. Each BAE has a initial default vocabulary if you selected one, make sure to add more!"
        redirect_to user_path(current_user)
      else
        flash[:errors] = "Something went wrong!"
        redirect_to new_bot_path
      end
    end
  end

  def edit
    if current_user == Bot.find(params[:id]).user || current_user.role == "Admin"
      @bot = Bot.find(params[:id])
    elsif !signed_in?
      authenticate_user!
    else
      @bot = Bot.find(params[:id])
      flash[:notice] = "You have no permission to edit this BAE"
      redirect_to user_bot_path(current_user, @bot)
    end
  end

  def update
    @bot = Bot.find(params[:id])
    @user = @bot.user
    if current_user == @user || current_user.role == "Admin"
      if @bot.update_attributes(bot_params)
        flash[:success] = "BAE edited successfully"
        redirect_to user_path(@user)
      else
        flash[:alert] = "Something went wrong"
        render :edit
      end
    else
      flash[:error] = "You have no permission to edit this BAE"
      render :edit
    end
  end

  def destroy
    @user = current_user
    @bot = Bot.find(params[:id])
    if current_user
      @bot.destroy
      flash[:notice] = "BAE deleted successfully"
      redirect_to user_path(@user)
    else
      flash[:error] = "You have no permission to delete this BAE"
      redirect_to user_path(@user)
    end
  end

  def reset
    @bot = Bot.find(params[:bot_id])
    @bot.update_conversation
    flash[:notice] = "Your conversation has been updated"
    redirect_to :back
  end

  protected

  def bot_params
    params.require(:bot).permit(
      :name,
      :gender,
      :age,
      :eye_color,
      :hair_color,
      :description,
      :user_id
    )
  end
end

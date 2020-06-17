class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: json_response(@users)
  end

  # GET /users/1
  def show
    render json: json_response(@user)
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      # basket is created after creating user successfully
      Order.create(user_id: @user.id) # default order_type is basket

      render json: json_response(@user, '201'), status: :created, location: @user
    else
      render json: json_response(@user.errors, '422'), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: json_response(@user)
    else
      render json: json_response(@user.errors, '422'), status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :phone)
    end
end

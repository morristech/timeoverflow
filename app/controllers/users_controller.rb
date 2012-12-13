class UsersController < ApplicationController
  respond_to :json

  before_filter do
    params[:user] &&= user_params
  end

  load_and_authorize_resource

  def index
    respond_with @users.includes(:categories)
  end

  def me
    head 401 and return unless current_user
    respond_with current_user
  end

  def show
    # @user = @users.includes(:categories).find(params[:id])
    respond_with @user
  end

  def create
    if @user.save
      respond_with @user, status: :created, location: @user
    else
      respond_with @user.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user.update_attributes(params[:user])
      respond_with @user, location: @user
    else
      respond_with @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def user_params
    fields_to_permit = %w"username email category_ids date_of_birth phone alt_phone password password_confirmation identity_document"
    fields_to_permit << "organization_id" if can? :manage, Organization
    fields_to_permit << "admin" << "registration_number" if current_user.admin?
    fields_to_permit << "superadmin" if current_user.superadmin?
    params[:user].permit(*fields_to_permit).tap &method(:ap)
  end
end

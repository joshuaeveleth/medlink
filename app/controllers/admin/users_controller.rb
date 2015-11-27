class Admin::UsersController < AdminController
  def set_country
    current_user.update country: Country.find(params[:country][:id])
    redirect_to (params[:next] || :back)
  end

  def select
    redirect_to edit_admin_user_path(params[:edit][:user_id])
  end

  def new
    @user = NewUserForm.new current_user.country.users.new, editor: current_user
    authorize @user
  end

  def create
    @user = NewUserForm.new current_user.country.users.new, editor: current_user

    if validate @user, params[:user]
      @user.save
      redirect_to country_roster_path, notice: I18n.t!("flash.user.added")
    else
      render :new
    end
  end

  def edit
    @user = AdminEditUserForm.new User.find(params[:id]), editor: current_user
  end

  def update
    @user = AdminEditUserForm.new User.find(params[:id]), editor: current_user

    if validate @user, params[:user]
      @user.save
      redirect_to country_roster_path, @user.flash
    else
      render :edit
    end
  end

  def inactivate
    user = User.find params[:id]
    authorize user
    user.inactivate!
    redirect_to :back, notice: I18n.t!("flash.user.inactive_user", user: user.name)
  end
end

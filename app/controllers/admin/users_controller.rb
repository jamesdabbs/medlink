class Admin::UsersController < AdminController
  def set_country
    id = params[:country][:country_id]
    redirect_to :back and return unless id.present?
    current_user.update country: Country.find(id)
    redirect_to :back, notice: I18n.t!("flash.country_selected", country: current_user.country.name)
  end

  def new
    @user = User.new
  end

  def create
    # This is a kludge to accomodate the edit user
    #   selection being on the new user (/admin home) page
    if id = params[:edit_user]
      if id.present?
        user = User.find id
        redirect_to edit_admin_user_path(user) and return
      else
        redirect_to new_admin_user_path, notice: I18n.t!("flash.user.none_selected") and return
      end
    end

    @user = User.new user_params.merge(password: SecureRandom.hex)

    if @user.save
      UserMailer.welcome(@user).deliver_later
      redirect_to new_admin_user_path, notice: I18n.t!("flash.user.added")
    else
      render :new
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user  = User.find params[:id]
    _attrs = @user.attributes
    if @user.update_attributes user_params
      diff = User::Change.new _attrs, @user
      _flash = if diff.changed?
        { success: I18n.t!("flash.user.changes", changes: diff.summary) }
      else
        { notice: I18n.t!("flash.user.no_changes") }
      end
      redirect_to new_admin_user_path, flash: _flash
    else
      render :edit
    end
  end

  def upload_csv
    @upload = User::Upload.new(
      params[:country_id], params[:csv], overwrite: params[:overwrite].present?)
    @upload.run!

    @upload.added.each { |u| UserMailer.welcome(u).deliver_later }

    if @upload.errors.any?
      @user = User.new
      render :new
    else
      flash[:success] = I18n.t! "flash.csv.valid", users: @upload.added.count
      redirect_to new_admin_user_path
    end
  end

  def editable_users
    User.where(country: active_country_id).order(last_name: :asc).map { |u| [u.name, u.id] }
  end
  helper_method :editable_users

  private # ----------

  def user_params
    p = params.require(:user).permit(:first_name, :last_name, :location,
      :country_id, :email, :pcv_id, :role, :time_zone,
      phones_attributes: [:id, :number, :_destroy])
    p[:phones_attributes].reject! { |_,ps| ps[:number].empty? }
    p
  end
end

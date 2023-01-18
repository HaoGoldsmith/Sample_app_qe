class PasswordResetsController < ApplicationController
  before_action :get_user,
                only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  # Case (1). выполняем функцию ниже(она приватна), только для действий эдит и апдейт

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase) #забираем введенный эмейл с хэша пассворд ресет
    if @user #если юзер найден
      @user.create_reset_digest #создаем очищающий диджест(ф-я?)
      @user.send_password_reset_email #отправляем письмо о сбросе пароля и выводим увед, затем редирект на рут урл
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else #если не найден, выводим увед
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def update
    # проверяет пуст ли пароль. если да - записывакм ошибку этого юзера(пароль, сообщение - не мб пустю возваращаем
    # страницу эдит)
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    #   если пароль не пуст и юзер апдейтится(с ф-ей ниже) - логинимся, выводим флеш, редирект на страницу юзера
    elsif @user.update(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil) #чтобы после захода обнулилось, и никто не нажал - назад-обновить
      flash[:success] = "Password has been reset."
      redirect_to @user
    #   в случае провала, опять выводим страницу эдит
    else
      render 'edit'
    end
  end

  def edit
  end

  private

  # уточни что такое пермит(что-то встроенное)
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? &&
      @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # Checks expiration of reset token. проверяет ф-ию password_reset_expired?, если 2 часа прошло, то новый урл с
  # новым паспорт ресетом(в вьюс-паспорт_ресетс-нью.хтмл)
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end

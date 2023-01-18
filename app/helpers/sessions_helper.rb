module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id #добавляет в дикт(хэш) сессия параметр юзер_ид равный идентификатору юзера
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id]) #если юзер_ид это ид, взятый из сессии
      @current_user ||= User.find_by(id: user_id) #то текущий юзер либо тот,что сейчас, либо им становится найденный по ид
    elsif (user_id = cookies.encrypted[:user_id]) #если юзер_ид это ид, взятый из куков(зашифрованный ид),
      # т.е сессия не открыта, но когда-то была создана
      user = User.find_by(id: user_id) #ищем юзера по этому ид
      if user && user.authenticated?(:remember, cookies[:remember_token]) #если нашли его и у него авторизовался ремембер токен
        log_in user #логинимся и делаем текущим юзером
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user && user == current_user
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember #используется функция ремембер класса юзер. запоминаем его
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end


end

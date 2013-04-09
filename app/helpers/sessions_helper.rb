module SessionsHelper

  def sign_in(user)
    session[:user_id] = user.id
    current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    current_user = nil
    session.delete(:user_id);
  end
  
  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= session[:user_id] and User.find(session[:user_id])
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Plese sign in."
    end
  end

end

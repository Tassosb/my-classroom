class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new omni_auth ]
  rate_limit to: 10, within: 3.minutes, only: :omni_auth, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def omni_auth
    auth = request.env['omniauth.auth']
    user = User.from_omni_auth(auth)
    
    if user.valid?
      start_new_session_for user, auth[:credentials]
      redirect_to after_authentication_url
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end

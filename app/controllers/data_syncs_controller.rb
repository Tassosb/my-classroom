class DataSyncsController < ApplicationController
  def create
    if GoogleAPI.session_authorized?(Current.session)
      data_sync = Current.user.data_syncs.create!
      data_sync.run!

      redirect_to root_path
    else
      redirect_to new_session_path
    end
  end
end

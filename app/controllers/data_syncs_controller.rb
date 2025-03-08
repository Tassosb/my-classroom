class DataSyncsController < ApplicationController
  def create
    data_sync = Current.user.data_syncs.create!
    data_sync.run!
    
    redirect_to root_path
  end
end
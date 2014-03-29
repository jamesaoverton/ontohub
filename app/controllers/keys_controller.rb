# 
# Manage ssh keys
# 
class KeysController < InheritedResources::Base
  
  before_filter :authenticate_user!
  load_and_authorize_resource

  actions :index, :new, :create, :destroy
  
  protected

  def begin_of_association_chain
    current_user
  end
  
end

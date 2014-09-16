class RepositoriesController < InheritedResources::Base

  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index]

  def create
    resource.user = current_user
    super
  end

  def update
    resource.convert_to_local! if params[:un_mirror]
    params[:repository].except! :source_address, :source_type, :remote_type
    super
  end

  def index
    @repositories = Repository.accessible_by(current_user)
    super
  end

  def destroy
    super
  rescue Ontology::DeleteError => e
    flash[:error] = e.message
    redirect_to resource
  end

  protected

  def collection
    super.order(:name)
  end

end

class ProjectsController < InheritedResources::Base

  belongs_to :ontology, optional: true
  before_filter :check_read_permissions

  if parent
    load_resource :ontology
    load_and_authorize_resource through: [:ontology]
  else
    load_and_authorize_resource
  end

  def create
    create! do |success, failure|
      if parent
        parent.projects << resource
        parent.save
      end
      success.html { redirect_to [*resource_chain, :projects] }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to [*resource_chain, :projects] }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to [*resource_chain, :projects] }
    end
  end


  private

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end
end

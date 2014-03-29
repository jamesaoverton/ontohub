class SshAccessController < InheritedResources::Base
  skip_authorization_check

  belongs_to :repository, finder: :find_by_path!

  def index
    allowed = SshAccess.determine_permission(
      *SshAccess.extract_permission_params(params, parent), parent)
    render json: {allowed: allowed}
  rescue => e# ensure that we always return a valid response
    render json: {allowed: false, reason: "internal server problem: #{e.message}"}
  end

end

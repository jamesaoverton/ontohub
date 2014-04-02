class FilesController < ApplicationController

  helper_method :repository, :ref, :oid, :path, :branch_name
  before_filter :check_write_permissions, only: [:new, :create, :update]
  before_filter :check_read_permissions

  OWL_API_HEADER_PARTS = ['text/xml;',
                          'text/html, image/gif, image/jpeg, *;']

  def files
    @info = repository.path_info(params[:path], oid)

    raise Repository::FileNotFoundError, path if @info.nil?

    if owl_api_header_in_accept_header?
      send_download(path, oid)
    elsif request.format == 'text/html' || @info[:type] != :file
      case @info[:type]
      when :file
        @file = repository.read_file(path, oid)
      when :file_base
        ontology = repository.ontologies.
                    where(basepath: File.basepath(@info[:entry][:path])).
                    order('id asc').first
        if request.query_string.present?
          ontology = ontology.children.
            where(name: request.query_string).first
        end
        redirect_to [repository, ontology]
      end
    else
      send_download(path, oid)
    end
  end

  def download
    send_download(path, oid)
  end

  def entries_info
    render json: repository.entries_info(oid, path)
  end

  def diff
    @message = repository.commit_message(oid)
    @changed_files = repository.changed_files(oid)
  end

  def history
    @per_page = 25
    page = @page = params[:page].nil? ? 1 : params[:page].to_i
    offset = page > 0 ? (page - 1) * @per_page : 0

    @ontology = repository.primary_ontology(path)

    if repository.empty?
      @commits = []
    else
      @current_file = repository.read_file(path, oid) if path && !repository.dir?(path)
      @commits = repository.commits(start_oid: oid, path: path, offset: offset, limit: @per_page)
    end
  end

  def new
    build_file
  end

  def create
    if build_file.valid?
      repository.save_file @file.file.path, @file.filepath, @file.message, current_user
      flash[:success] = "Successfully saved the uploaded file."
      if ontology = repository.ontologies.find_by_file(@file.filepath)
        redirect_to edit_repository_ontology_path(repository, ontology)
      else
        redirect_to fancy_repository_path(repository, path: @file.filepath)
      end
    else
      render :new
    end
  end

  def update
    if update_file.valid?
      repository.save_file @file.file.path, @file.filepath, @file.message, current_user
      FileUtils.rm_rf(@file.file.path)
      flash[:success] = "Successfully changed the file."
      redirect_to fancy_repository_path(repository, path: @file.filepath)
    else
      @info = repository.path_info(params[:path], oid)
      @file = repository.read_file(path, oid)

      @info[:file][:content] = params[:content]
      @file[:content] = params[:content]

      flash[:error] = @file.errors

      render :files
    end
  end

  protected

  def repository
    @repository ||= Repository.find_by_path!(params[:repository_id])
  end

  def ref
    params[:ref] || 'master'
  end

  def build_file
    args = params[:upload_file].merge({repository: repository}) unless params[:upload_file].nil?
    @file ||= UploadFile.new(args)
  end

  def update_file
    filepath = Rails.root.join('tmp', 'files', oid, "#{Time.now.nsec}_#{params[:path].split('/')[-1]}")
    FileUtils.mkdir_p(filepath.split[0])

    tmp_file = File.open(filepath, 'w+') do |f|
      f.write(params[:content])
    end

    @file = UploadFile.new(
      target_directory: params[:path].split('/')[0..-2].join('/'),
      target_filename: params[:path].split('/')[-1],
      message: params[:message],
      repository: repository,
      file: File.new(filepath))
  end

  def check_read_permissions
    authorize! :show, repository
  end

  def check_write_permissions
    authorize! :write, repository
  end

  def send_download(path, oid)
    render text: repository.read_file(path, oid)[:content],
           content_type: Mime::Type.lookup('application/force-download')
  end

  def commit_id
    @commit_id ||= repository.commit_id(params[:ref])
  end

  def oid
    @oid ||= commit_id[:oid] unless commit_id.nil?
  end

  def branch_name
    commit_id[:branch_name]
  end

  def path
    params[:path]
  end

  def owl_api_header_in_accept_header?
    OWL_API_HEADER_PARTS.any? do |owl_api_header_part|
      request.headers['Accept'].try(:include?, owl_api_header_part)
    end
  end

end

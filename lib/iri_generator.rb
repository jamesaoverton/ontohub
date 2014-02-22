class IriGenerator

  # SEP is short for SEPARATOR
  SEP = '/'
  CHILD_SEP = '?'

  class << self

    # There are three ways to get an iri by calling this method.
    # Each requires a repository as the first argument. We need
    # the repository mainly for its path attribute.
    #
    # As a Second parameter one can specify either path: or ontology:
    # ontology: Generate iri based on basepath of ontology
    # path: Generate iri based on absolute file-system path
    #
    # The third option is to specify repository, ontology and child_iri
    # which generates an iri for the child-ontology.
    def iri_for(repository, ontology: nil, path: nil, child_iri: nil)
      if ontology && child_iri
        determine_child_iri(repository, ontology, child_iri)
      elsif path
        determine_iri_with_path(repository, path)
      elsif ontology
        determine_iri_with_ontology(repository, ontology)
      else
        raise ArgumentError, 'arguments did not comply with signature'
      end
    end

    private
    def determine_child_iri(repository, ontology, child_iri)
      iri = clean(child_iri)
      if is_filepath?(iri)
        determine_iri_with_path(repository, iri)
      elsif has_uri_style?(iri)
        iri
      else
        "#{ontology.iri}#{CHILD_SEP}#{iri}"
      end
    end

    def determine_iri_with_path(repository, path)
      path = clean(path)
      if is_filepath?(path)
        iri_portion = reduce(repository, path)
        raise InvalidFileSystemPath unless iri_portion.include?(repository.path)
        ontohub_iri(iri_portion)
      end
    end

    def determine_iri_with_ontology(repository, ontology)
      ontohub_iri("#{repository.path}#{SEP}#{ontology.basepath}")
    end

    # Safeguard against 'iris' from hets-output, which
    # are parenthesized by angle-brackets.
    def clean(uncool_iri)
      uncool_iri.start_with?('<') ? uncool_iri[1..-2] : uncool_iri
    end

    # reduces a path to the relevant sub-repository
    # path for the file.
    def reduce(repository, path)
      repository_path = Regexp.escape(repository.path)
      match = path.match(%r{
        .+# match until repository_path is found
        (?<ontology_path>#{repository_path}.+)}x)
      # return without file extension
      match['ontology_path'].split('.').first
    end

    def ontohub_iri(path)
      "http://#{Settings.hostname}/#{path}"
    end

    def is_filepath?(iri)
      iri.start_with?('/')
    end

    def has_uri_style?(iri)
      iri.include?("://")
    end

    public :ontohub_iri

  end

end

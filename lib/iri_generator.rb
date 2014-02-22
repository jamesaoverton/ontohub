class IriGenerator

  # SEP is short for SEPARATOR
  SEP = '/'
  CHILD_SEP = '?'

  class << self

    def iri_for(repository, ontology: nil, path: nil, child_iri: nil)
      if ontology && child_iri
        determine_child_iri(repository, ontology, child_iri)
      elsif path
        determine_iri_with_path(repository, path)
      elsif ontology
        determine_iri_with_ontology(repository, ontology)
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
        iri_portion = reduce(path)
        raise InvalidFileSystemPath unless iri_portion.include?(repository.path)
        ontohub_iri(iri_portion)
      end
    end

    def determine_iri_with_ontology(repository, ontology)
      ontohub_iri("#{repository.path}#{SEP}#{ontology.basepath}")
    end

    def clean(uncool_iri)
      uncool_iri.start_with?('<') ? uncool_iri[1..-2] : uncool_iri
    end

    def reduce(repository, path)
      repository_path = Regexp.escape(repository.path)
      match = path.match(%r{
        .+# match until repository_path is found
        (?<ontology_path>#{repository_path}.+)}x)
      match['ontology_path']
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

  end

end

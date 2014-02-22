class IriGenerator



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
      if iri.start_with?('/')
        determine_iri_with_path(repository, iri)
      elsif iri.include?("://")
        iri
      else
        "#{ontology.iri}?#{iri}"
      end
    end

    def determine_iri_with_path(repository, path)
      path = clean(path)
      if path.start_with?('/')
        iri_portion = reduce(path)
        raise InvalidFileSystemPath unless iri_portion.include?(repository.path)
        ontohub_iri(iri_portion)
      end
    end

    def determine_iri_with_ontology(repository, ontology)
      ontohub_iri("#{repository.path}/#{ontology.basepath}")
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

  end

end

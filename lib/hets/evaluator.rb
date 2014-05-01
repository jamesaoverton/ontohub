module Hets
  class Evaluator
    attr_accessor :version, :path, :code_path
    attr_accessor :ontology, :user, :ontologies_count
    attr_accessor :code_document, :parser, :callback
    attr_accessor :concurrency, :dgnode_stack, :ontology_aliases
    attr_accessor :versions, :now, :dgnode_count

    def initialize(user, ontology, version: nil, path: nil, code_path: nil)
      self.version = version
      self.path = path
      self.code_path = code_path
      self.ontology = ontology
      self.user = user
      self.ontologies_count = 0
      establish_paths
      initialize_handling
    end

    def import
      callback = NodeEvaluator.new(self)
      code_document = Nokogiri::XML(File.open(code_path)) if code_path
      callback.process(:all, :start)
      parser.parse(callback: callback)
      callback.process(:all, :end)
    end

    def ontologies
      versions.map(&:ontology)
    end

    def next_dgnode_stack_id
      dgnode_stack.length
    end

    def dgnode_stack_id
      next_dgnode_stack_id - 1
    end

    private
    def establish_paths
      if version
        @path = version.xml_path
        @code_path = version.code_reference_path
      end
    end

    def initialize_handling
      self.parser = Parser.new(path)
      self.concurrency = ConcurrencyBalancer.new
      self.versions = []
      self.dgnode_stack = []
      self.ontology_aliases = {}
      self.now = Time.now
    end

  end
end

require 'ostruct'

module IRIGeneration

  # SEP is short for SEPARATOR
  SEP = '/'
  CHILD_SEP = '?'
  PART_SEP = '#'

  class Wrapper
    attr_accessor :host, :port, :scheme, :subject

    def initialize(host: nil, port: nil, scheme: nil)
      self.host = host || Settings.hostname
      self.port = port
      self.scheme = scheme || Settings.scheme
    end

    def base
      "#{scheme}://#{host}#{":#{port}" if port}"
    end

    def ontology=(ontology)
      self.subject = ontology
    end

    def child_ontology=(ontology)
      self.subject = ontology
    end

    def symbol=(symbol)
      self.subject = symbol
    end

    def mapping=(mapping)
      self.subject = mapping
    end

    def realize
      h = OpenStruct.new(subject.expand_hierarchy)
      [
        base,
        pathify(h.repository),
        pathify(h.ontology),
        childify(h.child_ontology),
        childify(h.mapping),
        partify(h.symbol),
      ].join('')
    end

    def to_s
      realize
    end

    private
    def pathify(arg)
      "#{SEP}#{stringify(arg)}" if arg
    end

    def childify(arg)
      "#{CHILD_SEP}#{stringify(arg)}" if arg
    end

    def partify(arg)
      "#{PART_SEP}#{stringify(arg)}" if arg
    end

    def stringify(arg)
      arg.respond_to?(:iri_component) ? arg.iri_component : arg.to_s
    end
  end

  def build_iri(*args, &block)
    wrapper = Wrapper.new(*args)
    wrapper.instance_eval(&block)
    wrapper.realize
  end

  def iri_for(subject)
    wrapper = Wrapper.new
    wrapper.subject = subject
    wrapper.to_s
  end

end

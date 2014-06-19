require 'ostruct'

module IRIGeneration

  # SEP is short for SEPARATOR
  SEP = '/'
  CHILD_SEP = '?'
  PART_SEP = '#'

  class Wrapper
    attr_accessor :host, :port, :scheme, :subject, :append

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

    def append_info!(info_hash)
      self.append ||= {}
      append.merge!(info_hash)
    end

    def realize
      h = OpenStruct.new(subject.expand_hierarchy)
      append = OpenStruct.new(self.append)
      [
        base,
        pathify(h.repository),
        pathify(h.ontology),
        pathify(append.path),
        childify(h.child_ontology),
        childify(h.mapping),
        childify(append.child),
        partify(h.symbol),
        partify(append.part),
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

  def iri_for(subject, append: {})
    wrapper = Wrapper.new
    wrapper.subject = subject
    wrapper.append_info!(append)
    wrapper.to_s
  end

end

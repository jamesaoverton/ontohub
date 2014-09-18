require 'spec_helper'

describe Hets, :needs_hets do

  after do
    File.delete @xml_path if @xml_path
  end

  context 'Output directory parameter' do
    before do
      xml_paths = Hets.parse(ontology_file('owl/pizza'), [], '/tmp')
      @xml_path = xml_paths.last
    end

    it 'correctly be used' do
      expect(@xml_path.starts_with?('/tmp')).to be(true)
    end
  end

  %w(owl/pizza.owl owl/generations.owl clif/cat.clif).each do |path|
    context path do
      let(:ontology) { create :ontology }
      let(:user) { create :user }

      before do
        xml_paths = Hets.parse(ontology_file(path), [], '/tmp')
        @xml_path = xml_paths.last
        @pp_path = xml_paths.first
      end

      it 'have created output file' do
        expect(File.exists?(@xml_path)).to be(true)
      end

      it 'have generated importable output' do
        expect { parse_this(user, ontology, @xml_path) }.not_to raise_error
      end
    end
  end

  context 'with url-catalog' do
    before do
      catalog = 'http://colore.oor.net=http://develop.ontohub.org/colore/ontologies'
      xml_paths = Hets.parse(ontology_file('clif/monoid'), [catalog], '/tmp')
      @xml_path = xml_paths.last
      @pp_path = xml_paths.first
    end

    it 'have created output file' do
      expect(File.exists?(@xml_path)).to be(true)
    end
  end

  it 'raise exception if provided with wrong file-format' do
    expect { Hets.parse(ontology_file('valid.xml')) }.
      to raise_error(Hets::ExecutionError)
  end
end

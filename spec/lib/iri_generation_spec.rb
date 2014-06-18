require 'spec_helper'

describe IRIGeneration do

  let(:instance) do
    class SampleInstance
      include IRIGeneration
    end
    SampleInstance.new
  end

  let(:repository) { create :repository, path: 'repo' }
  let(:ontology) { create :single_ontology, basepath: 'ontology', repository: repository }

  context 'shall generate correct ontohub-iri' do

    context 'from filesystem' do
      let(:iri) { instance.iri_for(ontology) }
      it 'should be a valid ontohub iri' do
        expect(iri).to eq("http://#{Settings.hostname}/repo/ontology")
      end
    end

    context 'for child-ontology' do
      let(:ontology_library) { create :distributed_ontology, basepath: 'library', repository: repository }

      before do
        ontology_library.iri = instance.iri_for(ontology_library)
        ontology.save
      end

      let(:iri) { instance.iri_for(ontology_library, append: {child: 'something'}) }

      it 'should be a valid ontohub iri' do
        expect(iri).to eq("http://#{Settings.hostname}/repo/library?something")
      end

    end

    context 'from full path' do
      let(:iri) { instance.iri_for(repository, append: {path: '/full/path/to/repo/something.clif'}) }

      it 'should be a valid ontohub iri' do
        expect(iri).to eq("http://#{Settings.hostname}/repo/something")
      end
    end

  end

end

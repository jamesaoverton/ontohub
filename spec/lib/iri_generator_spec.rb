require 'spec_helper'

describe IriGenerator do

  let(:repository) { create :repository, path: 'repo' }
  let(:ontology) { create :single_ontology, basepath: 'ontology', repository: repository }

  context 'shall generate correct ontohub-iri' do

    context 'from filesystem' do
      let(:iri) { IriGenerator.iri_for(repository, ontology: ontology) }
      it 'should be a valid ontohub iri' do
        expect(iri).to eq("http://#{Settings.hostname}/repo/ontology")
      end
    end

    context 'for child-ontology' do
      let(:ontology_library) { create :distributed_ontology, basepath: 'library', repository: repository }

      before do
        ontology_library.iri = IriGenerator.iri_for(repository, ontology: ontology_library)
        ontology.save
      end

      let(:iri) { IriGenerator.iri_for(repository, ontology: ontology_library, child_iri: 'something') }

      it 'should be a valid ontohub iri' do
        expect(iri).to eq("http://#{Settings.hostname}/repo/library?something")
      end

    end

    context 'from full path' do
      let(:iri) { IriGenerator.iri_for(repository, path: '/full/path/to/repo/something.clif') }

      it 'should be a valid ontohub iri' do
        expect(iri).to eq("http://#{Settings.hostname}/repo/something")
      end
    end

  end


end

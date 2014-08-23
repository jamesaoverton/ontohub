require 'spec_helper'

describe 'repository access' do

  context 'private repository' do
    let(:repository) { create :repository, access: 'private_rw' }

    context 'without access token' do
      it 'should not have a token yet' do
        expect(repository.access_token).to be_empty
      end
    end

    context 'after generate_access_token' do
      before do
        @access_token = repository.generate_access_token
      end

      it 'should generate a token' do
        expect(repository.access_token).not_to be_empty
      end

      it 'should associate with the generated token' do
        expect(repository.access_token.first).to eq(@access_token)
      end

      it 'should save the token' do
        expect(repository.access_token.first.persisted?).to be_truthy
      end
    end
  end
end

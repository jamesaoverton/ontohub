require 'spec_helper'

describe 'repository access' do

  context 'private repository' do
    let(:repository) { create :repository, access: 'private_rw' }

    context 'without access token' do
      it 'should not have a token yet' do
        expect(repository.access_token).to be_nil
      end
    end

    context 'after first access_token_get_or_generate' do
      before do
        @access_token = repository.access_token_get_or_generate
      end

      it 'should generate a token' do
        expect(repository.access_token).not_to be_nil
      end

      it 'should associate with the generated token' do
        expect(repository.access_token).to eq(@access_token)
      end

      it 'should save the token' do
        expect(repository.access_token.persisted?).to be_truthy
      end
    end

    context 'when already having a valid access token' do
      before do
        @access_token = repository.access_token_get_or_generate
        @access_token.expiration = 1.minutes.from_now
        @old_expiration = @access_token.expiration
        repository.access_token_get_or_generate
      end

      it 'should still be the same token' do
        expect(repository.access_token.token).to eq(@access_token.token)
      end

      it 'should have a later expiration date' do
        expect(@old_expiration < repository.access_token.expiration).to be_truthy
      end
    end

    context 'when already having an expired access token' do
      before do
        @access_token = repository.access_token_get_or_generate
        @access_token.expiration = (-1).minutes.from_now
        repository.access_token_get_or_generate
      end

      it 'should generate a new token' do
        expect(repository.access_token.token).not_to eq(@access_token.token)
      end
    end
  end
end

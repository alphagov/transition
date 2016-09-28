require 'rails_helper'
require 'transition/import/whitehall_orgs'

describe Transition::Import::WhitehallOrgs do
  context 'with an API response stubbed to fixtures' do
    subject(:whitehall_orgs) do
      Transition::Import::WhitehallOrgs.new('spec/fixtures/whitehall/orgs_abridged.yml')
    end

    it 'has 6 organisations' do
      expect(subject.organisations.size).to eq(6)
    end

    describe '#by_id' do
      subject(:ago) do
        whitehall_orgs.by_id[
          'https://whitehall-admin.production.alphagov.co.uk/api/organisations/attorney-generals-office'
        ]
      end

      it      { is_expected.to be_a(Hash) }
      specify { expect(ago['format']).to eq('Ministerial department') }

      describe '#details' do
        subject { super()['details'] }
        describe '#slug' do
          subject { super()['slug'] }
          it { is_expected.to eq('attorney-generals-office') }
        end
      end
    end
  end
end

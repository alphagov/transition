require 'spec_helper'
require 'transition/google/url_ingester'

describe Transition::Google::UrlIngester do
  TOO_FEW = 9
  let(:hostpath_rows) {[
    ['dpm.gov.uk', '/path', 30],
    ['dpm.gov.uk', '/path2', 20],
    ['dpm.gov.uk', '/path3', TOO_FEW],
    ['notdpm.gov.uk', '/path', 10]
  ]}

  subject(:ingester) { Transition::Google::UrlIngester.new('dpm') }

  before do
    # The only part we're stubbing is the pager, which normally talks to Google.
    # The rest is actual integration.
    ingester.stub(:results_pager).and_return(hostpath_rows)
  end

  context 'the org has no profile id' do
    it 'raises a RuntimeError' do
      create :site, abbr: 'dpm',
             organisation: create(:organisation, whitehall_slug: 'dpm', ga_profile_id: nil)
      expect { ingester.ingest! }.to raise_error(RuntimeError)
    end
  end

  context 'an org with a profile id exists' do
    it 'ingests only hits for known hosts above a threshold of 10' do
      create :site, abbr: 'dpm',
             organisation: create(:organisation, whitehall_slug: 'dpm')
      ingester.ingest!
      Hit.all.should have(2).hits
    end
  end
end

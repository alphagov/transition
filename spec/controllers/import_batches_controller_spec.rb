require 'spec_helper'

describe ImportBatchesController do
  let(:site)    { create :site, abbr: 'moj' }
  let(:gds_bob) { create(:gds_editor, name: 'Bob Terwhilliger') }

  describe '#new' do
    context 'without permission to edit' do
      def make_request
        get :new, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end
  end

  describe '#create without permission to edit' do
    def make_request
      post :create, site_id: site.abbr
    end

    it_behaves_like 'disallows editing by unaffiliated user'
  end

  describe '#create' do
    before do
      login_as gds_bob
    end

    context 'with valid parameters' do
      before do
        post :create, site_id: site.abbr, import_batch: {
          raw_csv: '/a,TNA', tag_list: ''
        }
      end

      it 'creates a batch for the site' do
        site.import_batches.count.should == 1
      end

      it 'creates entries for the batch' do
        site.import_batches.entries.count.should eql(1)
        entry = site.import_batches.first.entries.first
        entry.path.should eql('/a')
        entry.type.should eql('archive')
      end

      it 'redirects to the preview page' do
        expect(response).to redirect_to preview_site_import_batch_path(site, site.import_batches.first)
      end
    end
  end
end

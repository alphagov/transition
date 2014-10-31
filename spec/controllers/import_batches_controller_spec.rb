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

  describe '#create' do
    before do
      login_as gds_bob
    end

    context 'without permission to edit' do
      def make_request
        post :create, site_id: site.abbr
      end

      it_behaves_like 'disallows editing by unaffiliated user'
    end

    context 'with valid parameters' do
      let!(:whitelisted_host) { create :whitelisted_host, hostname: 'example.com' }
      let(:stem)              { "http://#{whitelisted_host.hostname}/"  }
      let(:long_url)          { "#{stem}#{'x' * (2048 - stem.length) }" }
      before do
        post :create, site_id: site.abbr, import_batch: {
          raw_csv: "/a,TNA\n/b,#{long_url}",
          tag_list: ''
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

      describe 'the archive entry' do
        subject { site.import_batches.first.entries.first }

        its(:path) { should eql('/a') }
        its(:type) { should eql('archive')}
      end

      describe 'the redirect entry' do
        subject { site.import_batches.first.entries.last }

        its(:path)    { should eql('/b') }
        its(:type)    { should eql('redirect')}
        its(:new_url) { should eql(long_url)}
      end

      it 'redirects to the preview page' do
        expect(response).to redirect_to preview_site_import_batch_path(site, site.import_batches.first)
      end
    end

    context 'with invalid parameters' do
      before do
        post :create, site_id: site.abbr, import_batch: {
          raw_csv: 'a,', tag_list: ''
        }
      end

      it 'does not create a batch for the site' do
        site.import_batches.count.should == 0
      end

      it 'redisplays the form' do
        expect(response).to render_template 'import_batches/new'
      end

      describe 'showing error messages' do
        render_views

        it 'shows error messages at the top of the form' do
          expect(response.body).to include('Enter at least one valid path or full URL')
        end
      end
    end
  end

  describe '#preview without permission to edit' do
    def make_request
      get :preview, site_id: site.abbr, id: 1
    end

    it_behaves_like 'disallows editing by unaffiliated user'
  end

  describe '#import' do
    let(:batch) { create(:import_batch, site: site) }

    before do
      login_as gds_bob
    end

    context 'a small batch' do
      def make_request
        post :import, site_id: site.abbr,
            import_batch: { update_existing: 'true' },
            id: batch.id
      end

      include_examples 'it processes a small batch inline'
    end

    context 'a large batch' do
      let(:large_batch) { create(:large_import_batch, site: site) }

      def make_request
        post :import, site_id: site.abbr,
              import_batch: { update_existing: 'true' },
              id: large_batch.id
      end

      include_examples 'it processes a large batch in the background'
    end

    context 'a batch which has been submitted already' do
      def make_request
        post :import, site_id: site.abbr, id: batch.id, import_batch: {}
      end

      include_examples 'it doesn\'t requeue a batch which has already been queued'
    end
  end
end

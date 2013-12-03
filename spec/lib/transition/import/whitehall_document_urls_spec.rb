require 'spec_helper'
require 'transition/import/whitehall_document_urls'

# From: https://github.com/airblade/paper_trail/tree/2.7-stable#turning-papertrail-offon
def with_versioning
  was_enabled = PaperTrail.enabled?
  PaperTrail.enabled = true
  begin
    yield
  ensure
    PaperTrail.enabled = was_enabled
  end
end

def csv_for(old_path, govuk_path, whitehall_state = 'published')
  StringIO.new(<<-END)
Old Url,New Url,Status,Slug,Admin Url,State
http://www.dft.gov.uk#{old_path},https://www.gov.uk#{govuk_path},301,new,http://whitehall-admin/#{rand(1000)},#{whitehall_state}
END
end

describe Transition::Import::WhitehallDocumentURLs do
  describe 'from_csv' do
    let(:as_user) { create(:user, name: 'C-3PO', is_robot: true) }

    context 'site and host exists' do
      let!(:site) { create(:site_with_default_host, abbr: 'www.dft', query_params: 'significant') }

      before do
        Transition::Import::WhitehallDocumentURLs.new(as_user).from_csv(csv)
      end

      context 'rosy case' do
        let(:csv) { csv_for('/oldurl', '/new') }

        subject(:mapping) { Mapping.first }

        specify { Mapping.count.should == 1 }

        its(:site)        { should == site }
        its(:path)        { should == '/oldurl' }
        its(:new_url)     { should == 'https://www.gov.uk/new' }
        its(:http_status) { should == '301' }
      end

      context 'Old URL is not canonical, no mapping' do
        let(:csv) { csv_for('/oldurl?significant=aha&ignored=ohyes', '/new') }

        subject(:mapping) { Mapping.first }

        specify { Mapping.count.should == 1 }

        its(:site)        { should == site }
        its(:path)        { should == '/oldurl?significant=aha' }
        its(:new_url)     { should == 'https://www.gov.uk/new' }
        its(:http_status) { should == '301' }
      end

      context 'existing mapping and the Old Url is not canonical' do
        let(:mapping) { create(:mapping, site: site, path: '/oldurl?significant=aha', new_url: 'https://www.gov.uk/mediocre') }
        let(:csv) { csv_for('/oldurl?significant=aha&ignored=ohyes', '/amazing') }

        subject(:mapping) { Mapping.first }

        specify { Mapping.count.should == 1 }

        its(:site)        { should == site }
        its(:path)        { should == '/oldurl?significant=aha' }
        its(:new_url)     { should == 'https://www.gov.uk/amazing' }
        its(:http_status) { should == '301' }
      end

      context 'existing mapping edited by a human' do
        let(:csv) {
          create(:mapping, from_redirector: true, site: site, path: '/oldurl', new_url: 'https://www.gov.uk/curated')
          csv_for('/oldurl', '/automated')
        }

        subject(:mapping) { Mapping.first }

        specify { Mapping.count.should == 1 }

        its(:new_url)     { should == 'https://www.gov.uk/curated' }
      end

      context 'CSV row without an Old Url' do
        let(:csv) { StringIO.new(<<-END)
Old Url,New Url,Status,Slug,Admin Url,State
,https://www.gov.uk/a-document,301,new,http://whitehall-admin/#{rand(1000)},published
END
}

        specify { Mapping.count.should == 0 }
      end

      context 'row has a State which isn\'t "published"' do
        let(:csv) { csv_for('/oldurl', '/new', 'draft') }

        specify { Mapping.all.count.should == 0 }
      end

      context 'Old Url is unparseable' do
        let(:csv) { StringIO.new(<<-END)
Old Url,New Url,Status,Slug,Admin Url,State
http://_____/old,https://www.gov.uk/a-document,301,new,http://whitehall-admin/#{rand(1000)},published
END
}

        specify { Mapping.all.count.should == 0 }
      end
    end

    context 'site is not managed by transition' do
      let!(:site) { create(:site_with_default_host, abbr: 'www.dft', managed_by_transition: false) }
      let(:csv) { csv_for('/oldurl', '/new') }

      it 'logs it' do
        Rails.logger.should_receive(:warn).with("Skipping mapping for a site managed by redirector in Whitehall URL CSV: 'www.dft.gov.uk'")
        Transition::Import::WhitehallDocumentURLs.new(as_user).from_csv(csv)
      end
    end

    context 'testing version recording' do
      let!(:site) { create(:site_with_default_host, abbr: 'www.dft', query_params: 'significant') }
      let(:csv) { csv_for('/oldurl', '/new') }

      before do
        with_versioning do
          Transition::Import::WhitehallDocumentURLs.new(as_user).from_csv(csv)
        end
      end

      subject(:mapping) { Mapping.first }

      specify 'records the changes being made by a robot user' do
        mapping.versions.size.should == 1
        mapping.versions.first.whodunnit.should == as_user.id.to_s
      end

      specify 'reverts the whodunnit user' do
        ::PaperTrail.whodunnit.should be_nil
      end
    end

    context 'no site/host for Old Url' do
      let(:csv) { csv_for('/oldurl', '/amazing') }

      it 'logs an unknown host' do
        Rails.logger.should_receive(:warn).with("Skipping mapping for unknown host in Whitehall URL CSV: 'www.dft.gov.uk'")
        Transition::Import::WhitehallDocumentURLs.new(as_user).from_csv(csv)
      end
    end
  end
end

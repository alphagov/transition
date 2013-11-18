require 'spec_helper'
require 'transition/import/whitehall_document_urls'


def csv_for(old_path, govuk_path, whitehall_state = 'published')
  StringIO.new(<<-END)
Old Url,New Url,Status,Slug,Admin Url,State
http://www.dft.gov.uk#{old_path},https://www.gov.uk#{govuk_path},301,new,http://whitehall-admin/#{rand(1000)},#{whitehall_state}
END
end

describe Transition::Import::WhitehallDocumentURLs do
  describe 'from_csv' do
    context 'site and host exists' do
      let!(:site) { create(:site_with_default_host, abbr: 'www.dft', query_params: 'significant') }

      before do
        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
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

    context 'no site/host for Old Url' do
      let(:csv) { csv_for('/oldurl', '/amazing') }

      it 'logs an unknown host' do
        Rails.logger.should_receive(:warn).with("Skipping mapping for unknown host in Whitehall URL CSV: 'www.dft.gov.uk'")
        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
      end
    end
  end
end

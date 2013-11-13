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
    context 'published documents' do
      it 'adds a new mapping' do
        site = create(:site_with_default_host, abbr: 'www.dft')
        csv =  csv_for('/oldurl','/new')

        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
        Mapping.all.count.should == 1
        mapping = Mapping.first
        mapping.site.should == site
        mapping.path.should == '/oldurl'
        mapping.new_url.should == 'https://www.gov.uk/new'
        mapping.http_status.should == '301'
      end

      it 'canonicalises the URL before creating a new mapping' do
        site = create(:site_with_default_host, abbr: 'www.dft', query_params: 'significant')
        csv =  csv_for('/oldurl?significant=aha&ignored=ohyes','/new')

        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
        Mapping.all.count.should == 1
        mapping = Mapping.first
        mapping.site.should == site
        mapping.path.should == '/oldurl?significant=aha'
        mapping.new_url.should == 'https://www.gov.uk/new'
        mapping.http_status.should == '301'
      end

      it 'canonicalises the URL to find the one to update' do
        site = create(:site_with_default_host, abbr: 'www.dft', query_params: 'significant')
        mapping = create(:mapping, site: site, path: '/oldurl?significant=aha', new_url: 'https://www.gov.uk/mediocre')
        csv =  csv_for('/oldurl?significant=aha&ignored=ohyes','/amazing')

        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
        Mapping.all.count.should == 1
        mapping.reload
        mapping.site.should == site
        mapping.path.should == '/oldurl?significant=aha'
        mapping.new_url.should == 'https://www.gov.uk/amazing'
        mapping.http_status.should == '301'
      end

      it 'logs an unknown host' do
        Rails.logger.should_receive(:warn).with("Skipping mapping for unknown host in Whitehall URL CSV: 'www.dft.gov.uk'")
        csv =  csv_for('/oldurl','/amazing')
        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
      end

      it 'skips rows without an Old Url' do
        csv = StringIO.new(<<-END)
Old Url,New Url,Status,Slug,Admin Url,State
,https://www.gov.uk/a-document,301,new,http://whitehall-admin/#{rand(1000)},published
    END
        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
        Mapping.all.count.should == 0
      end

      it 'skips rows with a State of anything but "published"' do
        site = create(:site_with_default_host, abbr: 'www.dft')
        csv =  csv_for('/oldurl', '/new', 'draft')

        Transition::Import::WhitehallDocumentURLs.new.from_csv(csv)
        Mapping.all.count.should == 0
      end

      it 'handles parse failures of Old Url'
    end
  end
end

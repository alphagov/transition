require 'spec_helper'

describe View::Mappings::BulkAdder do
  let!(:site) { create(:site) }

  describe '#raw_paths' do
    subject { View::Mappings::BulkAdder.new(site, { paths: paths_input }).raw_paths }

    context 'empty string' do
      let(:paths_input) { '' }

      it { should be_an(Array) }
      it { should have(0).paths }
    end

    context 'single line' do
      let(:paths_input) { '/a' }

      it { should eql(['/a']) }
    end

    context 'multiple lines' do
      let(:paths_input) { "a\r\nb\rc\nd" }

      it { should eql(['a', 'b', 'c', 'd']) }
    end

    context 'multiple lines with starting and trailing whitespace' do
      let(:paths_input) { "   a    \r\nb    \rc\n     d" }

      it { should eql(['a', 'b', 'c', 'd']) }
    end

    context 'multiple realistic paths' do
      let(:paths_input) { "/sitecontent/documents/countries/491163/pvs-dis?view=binary\r\n/about us with spaces\r/arbitrary%20punctuation%3E" }

      it { should eql(
        [
          "/sitecontent/documents/countries/491163/pvs-dis?view=binary",
          "/about us with spaces",
          "/arbitrary%20punctuation%3E"
        ]
      )}
    end

    context 'multiple realistic paths with blank/whitespace lines in between' do
      let(:paths_input) { "\n/sitecontent/documents/countries/491163/pvs-dis?view=binary\r\n\r/about us with spaces\n        \n\n\n\n\n\n\n\r/arbitrary%20punctuation%3E" }

      it { should eql(
        [
          "/sitecontent/documents/countries/491163/pvs-dis?view=binary",
          "/about us with spaces",
          "/arbitrary%20punctuation%3E"
        ]
      )}
    end
  end

  describe '#raw_hosts' do
    subject { View::Mappings::BulkAdder.new(site, { paths: paths_input }).raw_hosts }

    context 'can parse the hostname without < and > characters affecting the parsing' do
      let(:paths_input) { "http://www.attorneygeneral.gov.uk/>text<" }

      it { should eql(["www.attorneygeneral.gov.uk"]) }
    end
  end

  describe '#site_has_hosts?' do
    subject { View::Mappings::BulkAdder.new(site, { paths: paths_input }).site_has_hosts? }

    describe 'hosts not part of the current site should be false' do
      let(:paths_input) { "http://www.google.com/test" }
      it { should be_false }
    end

    describe 'multiple incorrect hosts should be false' do
      let(:paths_input) { "http://www.google.com/google\nhttp://www.yahoo.com/yahoo" }
      it { should be_false }
    end

    describe 'a combination of correct and incorrect hosts should be false' do
      let(:paths_input) { "http://#{site.default_host.hostname}/about\nhttp://www.yahoo.com/yahoo" }
      it { should be_false }
    end

    describe 'a combination of paths and incorrect hosts should be false' do
      let(:paths_input) { "/about\nhttp://www.yahoo.com/yahoo" }
      it { should be_false }
    end

    describe 'hosts part of the current site should be true' do
      let(:paths_input) { "http://#{site.default_host.hostname}/about\nhttp://#{site.default_host.hostname}/another" }
      it { should be_true }
    end
    
    describe 'invalid hosts should be false' do
      let(:paths_input) { "http//go<oglecom" }
      it { should be_false }
    end

    describe 'paths should be true' do
      let(:paths_input) { "/path" }
      it { should be_true }
    end
  end

  describe '#canonical_paths' do
    subject { View::Mappings::BulkAdder.new(site, { paths: paths_input }).canonical_paths }

    describe 'multiple raw paths are canonicalized' do
      let(:paths_input) { "/sitecontent/documents/countries/491163/pvs-dis?view=binary\n/about us with spaces\n/LOWER" }

      it { should eql(
        [
          "/sitecontent/documents/countries/491163/pvs-dis",
          "/about%20us%20with%20spaces",
          "/lower",
        ]
      )}
    end

    describe 'paths which canonicalize to empty strings are ignored' do
      let(:paths_input) { "noslash" }

      it { should eql([]) }
    end

    describe 'paths which are duplicated once canonicalized are de-duplicated' do
      let(:paths_input) { "/about\n/another\n/about?view=on\n/about?view=off" }

      it { should eql(
        [
          "/about",
          "/another",
        ]
      )}
    end

    describe '< and > characters are encoded in paths' do
      let(:paths_input) { "/>text<" }

      it { should eql(["/%3etext%3c"]) }
    end
  end

  describe '#existing_mappings' do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists_already') }
    subject { View::Mappings::BulkAdder.new(site, { paths: paths_input, http_status: '410' }).existing_mappings }

    context 'existing mapping\'s path is submitted' do
      let(:paths_input) { "/exists_already\n/new" }

      it { should have(1).mapping }

      it 'should only contain the existing mapping' do
        expect(subject[0]).to eql(existing_mapping)
      end
    end

    context 'existing mapping\'s path is not submitted' do
      let(:paths_input) { "/new\n/another_new" }

      its(:size) { should eql(0) }
    end
  end

  describe '#all_mappings' do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists_already') }
    subject { View::Mappings::BulkAdder.new(site, { paths: paths_input, http_status: '410' }).all_mappings }

    context 'with only valid paths input' do
      let(:paths_input) { "/exists_already\n/a\n/b" }

      it 'should include a mapping for each valid path in the input' do
        expect(subject).to have(3).mappings
      end

      it 'should be in the same order as the paths were input' do
        expected_path_order = ['/exists_already', '/a', '/b']
        expect(subject.map(&:path)).to eql(expected_path_order)
      end

      it 'should not have created mappings which did not already exist' do
        expected_persisteds = [true, false, false]
        expect(subject.map(&:persisted?)).to eql(expected_persisteds)
      end

      it 'should not assign http_status to mappings which do not already exist' do
        expected_statuses = ['410', nil, nil]
        expect(subject.map(&:http_status)).to eql(expected_statuses)
      end
    end

    context 'with an invalid path in the input' do
      let(:paths_input) { "/exists_already\n/a\nnoslash" }

      it 'should not include a mapping for the invalid path' do
        expect(subject).to have(2).mappings
      end
    end
  end

  describe '#params_errors' do
    let(:paths_input)   { nil }
    let(:http_status)   { nil }
    let(:new_url)       { nil }

    subject do
      View::Mappings::BulkAdder.new(
        site, { paths: paths_input, http_status: http_status, new_url: new_url }).params_errors
    end

    describe 'when no http_status is given, there is an error for http_status' do
      its([:http_status]) { should eql(I18n.t('mappings.bulk.http_status_invalid')) }
    end

    describe 'when no valid paths are given, there is an error for paths' do
      let(:paths_input) { 'a' }

      its([:paths]) { should eql(I18n.t('mappings.bulk.add.paths_empty')) }
    end

    describe 'when a new_url is required but an invalid new_url is given, there is an error for new_url' do
      let(:http_status) { '301' }
      let(:new_url)     { '________' }

      its([:new_url]) { should eql(I18n.t('mappings.bulk.new_url_invalid')) }
    end
  end

  describe '#create_or_update!', versioning: true do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists', http_status: '410') }
    let(:tag_list) { nil }

    let(:adder)  { View::Mappings::BulkAdder.new(site, params) }
    let(:params) { {
      paths:           paths_input,
      http_status:     http_status,
      new_url:         new_url,
      update_existing: update_existing,
      tag_list:        tag_list
    } }

    # We expect this to never be called with invalid data because params_invalid?
    # should be called first to display error messages on the form, but in case
    # this method is called without data being validated first, check that it
    # doesn't blow up or bypass validation when attempting to create the mappings.
    context 'with invalid data: a redirect without a new_url' do
      let(:paths_input)     { "/a\n/B\n/c?canonical=no\n/exists" }
      let(:http_status)     { '301' }
      let(:new_url)         { '' }
      let(:update_existing) { "true" }

      before { adder.create_or_update! }

      specify 'there are no new mappings' do
        expect(site.mappings.count).to eql(1)
      end

      describe 'the existing mapping is unchanged' do
        subject { existing_mapping }

        its(:http_status) { should eql('410') }
        its(:new_url)     { should be_nil }
      end

      it 'has one outcome symbol for each failure' do
        adder.outcomes.should eql([
          :creation_failed, :creation_failed, :creation_failed, :update_failed
        ])
      end
    end

    context 'with valid data' do
      let(:paths_input) { "/a\n/B\n/c?canonical=no\n/exists" }
      let(:http_status) { '301' }
      let(:new_url)     { 'www.gov.uk' }
      let(:tag_list)    { 'fee, fi, FO' }

      before { adder.create_or_update! }

      shared_examples 'the new mappings were correctly created' do
        subject(:new_mappings) { Mapping.where(path: ['/a', '/b', '/c']) }

        specify 'there are 3 new mappings' do
          expect(new_mappings.count).to eql(3)
        end

        specify 'all new mappings are redirects' do
          expect(new_mappings.where(http_status: '301').count).to eql(3)
        end

        specify 'all new mappings have the correct new_url' do
          expect(new_mappings.where(new_url: 'https://www.gov.uk').count).to eql(3)
        end

        specify 'all new mappings have a version recording their creation' do
          new_mappings.each do |m|
            expect(m.versions.last.event).to eql('create')
          end
        end
      end

      context 'when not updating existing mappings' do
        let(:update_existing) { "false" }

        it_behaves_like 'the new mappings were correctly created'

        it 'has one symbol per outcome' do
          adder.outcomes.should eql([:created, :created, :created, :not_updating])
        end

        describe 'the pre-existing mapping' do
          subject { existing_mapping.reload }

          its(:http_status) { should eql('410') }

          it 'has no new history after its creation' do
            expect(existing_mapping.versions.last.event).to eql('create')
          end

          it 'has not updated its tags' do
            expect(existing_mapping.tag_list).to be_empty
          end
        end
      end

      context 'when updating existing mappings' do
        let!(:existing_mapping) {
          create(:mapping, site: site, path: '/exists', http_status: '410', tag_list: 'fum')
        }
        let(:update_existing)   { "true" }

        it_behaves_like 'the new mappings were correctly created'

        it 'has one symbol per outcome' do
          adder.outcomes.should eql([:created, :created, :created, :updated])
        end

        describe 'the pre-existing mapping' do
          subject { existing_mapping.reload }

          its(:http_status) { should eql('301') }
          its(:new_url)     { should eql('https://www.gov.uk') }
          its(:tag_list)    { should =~ %w(fee fi fo fum) }

          it 'has a version recording the update' do
            expect(existing_mapping.versions.last.event).to eql('update')
          end
        end
      end
    end
  end

  describe '#success_message' do
    let(:params) { {
      paths:           "/a\n/B\n/c?canonical=no\n/might-exist",
      http_status:     '410',
      update_existing: 'true',
      tag_list:        'fee, fi, FO'
    } }

    let(:bulk_adder) { View::Mappings::BulkAdder.new(site, params) }

    subject { bulk_adder.success_message }

    context 'when updating at least one existing mapping' do
      let!(:existing_mapping) { create(:mapping, site: site, path: '/might-exist', http_status: '410') }

      before { bulk_adder.create_or_update! }

      it { should eql('3 mappings created and 1 mapping updated. All tagged with "fee, fi, fo".') }
    end

    context 'there are no pre-existing mappings' do
      before  { bulk_adder.create_or_update! }

      context 'when creating some mappings and updating none' do
        it { should eql('4 mappings created and tagged with "fee, fi, fo". 0 mappings updated.') }
      end

      context 'when creating some mappings, updating none and tagging none' do
        before { params.delete(:tag_list) }

        it { should eql('4 mappings created. 0 mappings updated.') }
      end
    end
  end
end

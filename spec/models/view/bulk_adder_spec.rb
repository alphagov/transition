require 'spec_helper'

describe View::Mappings::BulkAdder do
  let!(:site) { create(:site) }

  describe '#raw_paths' do
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input }, '').raw_paths }

    context 'empty string' do
      before { @paths_input = '' }

      it { should be_an(Array) }
      it { should have(0).paths }
    end

    context 'single line' do
      before { @paths_input = '/a' }

      it { should eql(['/a']) }
    end

    context 'multiple lines' do
      before { @paths_input = "a\r\nb\rc\nd" }

      it { should eql(['a', 'b', 'c', 'd']) }
    end

    context 'multiple lines with starting and trailing whitespace' do
      before { @paths_input = "   a    \r\nb    \rc\n     d" }

      it { should eql(['a', 'b', 'c', 'd']) }
    end

    context 'multiple realistic paths' do
      before { @paths_input = "/sitecontent/documents/countries/491163/pvs-dis?view=binary\r\n/about us with spaces\r/arbitrary%20punctuation%3E" }

      it { should eql(
        [
          "/sitecontent/documents/countries/491163/pvs-dis?view=binary",
          "/about us with spaces",
          "/arbitrary%20punctuation%3E"
        ]
      )}
    end

    context 'multiple realistic paths with blank/whitespace lines in between' do
      before { @paths_input = "\n/sitecontent/documents/countries/491163/pvs-dis?view=binary\r\n\r/about us with spaces\n        \n\n\n\n\n\n\n\r/arbitrary%20punctuation%3E" }

      it { should eql(
        [
          "/sitecontent/documents/countries/491163/pvs-dis?view=binary",
          "/about us with spaces",
          "/arbitrary%20punctuation%3E"
        ]
      )}
    end
  end

  describe '#canonical_paths' do
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input }, '').canonical_paths }

    describe 'multiple raw paths are canonicalized' do
      before { @paths_input = "/sitecontent/documents/countries/491163/pvs-dis?view=binary\n/about us with spaces\n/LOWER" }

      it { should eql(
        [
          "/sitecontent/documents/countries/491163/pvs-dis",
          "/about%20us%20with%20spaces",
          "/lower",
        ]
      )}
    end

    describe 'paths which canonicalize to empty strings are ignored' do
      before { @paths_input = "noslash" }

      it { should eql([]) }
    end

    describe 'paths which are duplicated once canonicalized are de-duplicated' do
      before { @paths_input = "/about\n/another\n/about?view=on\n/about?view=off" }

      it { should eql(
        [
          "/about",
          "/another",
        ]
      )}
    end
  end

  describe '#existing_mappings' do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists_already') }
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: '410' }, '').existing_mappings }

    context 'existing mapping\'s path is submitted' do
      before { @paths_input = "/exists_already\n/new" }

      it { should have(1).mapping }

      it 'should only contain the existing mapping' do
        expect(subject[0]).to eql(existing_mapping)
      end
    end

    context 'existing mapping\'s path is not submitted' do
      before { @paths_input = "/new\n/another_new" }

      its(:size) { should eql(0) }
    end
  end

  describe '#all_mappings' do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists_already') }
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: '410' }, '').all_mappings }

    context 'with only valid paths input' do
      before { @paths_input = "/exists_already\n/a\n/b" }

      it 'should include a mapping for each valid path in the input' do
        expect(subject).to have(3).mappings
      end

      it 'should be in the same order as the paths were input' do
        expected_path_order = ['/exists_already', '/a', '/b']
        expect(subject.map { |m| m.path }).to eql(expected_path_order)
      end

      it 'should not have created mappings which did not already exist' do
        expected_persisteds = [true, false, false]
        expect(subject.map { |m| m.persisted? }).to eql(expected_persisteds)
      end

      it 'should not assign http_status to mappings which do not already exist' do
        expected_statuses = ['410', nil, nil]
        expect(subject.map { |m| m.http_status }).to eql(expected_statuses)
      end
    end

    context 'with an invalid path in the input' do
      before { @paths_input = "/exists_already\n/a\nnoslash" }

      it 'should not include a mapping for the invalid path' do
        expect(subject).to have(2).mappings
      end
    end
  end

  describe '#params_errors' do
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: @http_status, new_url: @new_url }, '').params_errors }

    describe 'when no http_status is given, there is an error for http_status' do
      its([:http_status]) { should eql(View::Mappings::BulkAdder::ERRORS[:http_status_invalid]) }
    end

    describe 'when no paths are given, there is an error for paths' do
      before do
        @paths_input = ''
      end

      its([:paths]) { should eql(View::Mappings::BulkAdder::ERRORS[:paths_empty]) }
    end

    describe 'when a new_url is required but an invalid new_url is given, there is an error for new_url' do
      before do
        @http_status = '301'
        @new_url = '________'
      end

      its([:new_url]) { should eql(View::Mappings::BulkAdder::ERRORS[:new_url_invalid]) }
    end
  end

  describe '#create!' do
    subject { site.mappings }

    def call_create
      View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: @http_status, new_url: @new_url }, '').create!
    end

    context 'with valid data' do
      before do
        @paths_input = "/a\n/B\n/c?canonical=no"
        @http_status = '301'
        @new_url = 'www.gov.uk'
        call_create
      end

      it { should have(3).mappings }

      specify 'all mappings are redirects' do
        expect(Mapping.where(http_status: '301').count).to eql(3)
      end

      specify 'all mappings have the correct new_url' do
        expect(Mapping.where(new_url: 'https://www.gov.uk').count).to eql(3)
      end

      specify 'all paths are canonical' do
        expect(Mapping.pluck(:path)).to eql(['/a', '/b', '/c'])
      end
    end
  end
end

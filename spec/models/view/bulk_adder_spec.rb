require 'spec_helper'

describe View::Mappings::BulkAdder do
  describe '#raw_paths' do
    let!(:site) { create(:site) }
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
    let!(:site) { create(:site) }
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

  describe '#params_errors' do
    let!(:site) { create(:site) }
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: @http_status }, '').params_errors }

    describe 'when no paths are given to archive, there is an error' do
      before do
        @paths_input = ''
        @http_status = '410'
      end

      it { should have(1).errors }
    end
  end
end

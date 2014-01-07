require 'spec_helper'

describe View::Mappings::BulkAdder do
  describe '#paths' do
    let!(:site) { create(:site) }
    subject(:paths) { View::Mappings::BulkAdder.new(site, { paths: @paths_input }, '').paths }

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
end

require 'spec_helper'

describe View::Mappings::BulkAdder do
  let!(:site) { create(:site) }

  describe '#raw_paths' do
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input }).raw_paths }

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
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input }).canonical_paths }

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
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: '410' }).existing_mappings }

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
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: '410' }).all_mappings }

    context 'with only valid paths input' do
      before { @paths_input = "/exists_already\n/a\n/b" }

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
      before { @paths_input = "/exists_already\n/a\nnoslash" }

      it 'should not include a mapping for the invalid path' do
        expect(subject).to have(2).mappings
      end
    end
  end

  describe '#params_errors' do
    subject { View::Mappings::BulkAdder.new(site, { paths: @paths_input, http_status: @http_status, new_url: @new_url }).params_errors }

    describe 'when no http_status is given, there is an error for http_status' do
      its([:http_status]) { should eql(I18n.t('mappings.bulk.http_status_invalid')) }
    end

    describe 'when no valid paths are given, there is an error for paths' do
      before do
        @paths_input = 'a'
      end

      its([:paths]) { should eql(I18n.t('mappings.bulk.add.paths_empty')) }
    end

    describe 'when a new_url is required but an invalid new_url is given, there is an error for new_url' do
      before do
        @http_status = '301'
        @new_url = '________'
      end

      its([:new_url]) { should eql(I18n.t('mappings.bulk.new_url_invalid')) }
    end
  end

  describe '#create_or_update!', versioning: true do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists', http_status: '410') }

    def call_create_or_update
      params = {
        paths:           @paths_input,
        http_status:     @http_status,
        new_url:         @new_url,
        update_existing: @update_existing
      }
      @adder = View::Mappings::BulkAdder.new(site, params)
      @adder.create_or_update!
    end

    # We expect this to never be called with invalid data because params_invalid?
    # should be called first to display error messages on the form, but in case
    # this method is called without data being validated first, check that it
    # doesn't blow up or bypass validation when attempting to create the mappings.
    context 'with invalid data: a redirect without a new_url' do
      before do
        @paths_input     = "/a\n/B\n/c?canonical=no\n/exists"
        @http_status     = '301'
        @new_url         = ''
        @update_existing = "true"
        call_create_or_update
      end

      specify 'there are no new mappings' do
        expect(site.mappings.count).to eql(1)
      end

      describe 'the existing mapping is unchanged' do
        subject { existing_mapping }

        its(:http_status) { should eql('410') }
        its(:new_url)     { should be_nil }
      end

      describe 'outcomes' do
        subject { @adder.outcomes }

        it { should eql([:creation_failed, :creation_failed, :creation_failed, :update_failed]) }
      end
    end

    context 'with valid data' do
      before do
        @paths_input     = "/a\n/B\n/c?canonical=no\n/exists"
        @http_status     = '301'
        @new_url         = 'www.gov.uk'
      end

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
        before do
          @update_existing = "false"
          call_create_or_update
        end

        it_behaves_like 'the new mappings were correctly created'

        describe 'outcomes' do
          subject { @adder.outcomes }

          it { should eql([:created, :created, :created, :not_updating]) }
        end

        describe 'the pre-existing mapping' do
          subject { existing_mapping.reload }

          its(:http_status) { should eql('410') }

          it 'has no new history after its creation' do
            expect(existing_mapping.versions.last.event).to eql('create')
          end
        end
      end

      context 'when updating existing mappings' do
        before do
          @update_existing = "true"
          call_create_or_update
        end

        it_behaves_like 'the new mappings were correctly created'

        describe 'outcomes' do
          subject { @adder.outcomes }

          it { should eql([:created, :created, :created, :updated]) }
        end

        describe 'the pre-existing mapping' do
          subject { existing_mapping.reload }

          its(:http_status) { should eql('301') }
          its(:new_url)     { should eql('https://www.gov.uk') }

          it 'has a version recording the update' do
            expect(existing_mapping.versions.last.event).to eql('update')
          end
        end
      end
    end
  end

  describe '#success_message' do
    let!(:existing_mapping) { create(:mapping, site: site, path: '/exists', http_status: '410') }

    before do
      params = {
        paths:           "/a\n/B\n/c?canonical=no\n/exists",
        http_status:     '410',
        update_existing: 'true'
      }
      @adder = View::Mappings::BulkAdder.new(site, params)
      @adder.create_or_update!
    end

    subject { @adder.success_message }

    it { should eql('3 mappings created and 1 mapping updated.') }
  end
end

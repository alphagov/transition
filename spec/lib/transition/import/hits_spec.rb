require 'rails_helper'
require 'transition/import/hits'
require 'transition/import/iis_access_log_parser'

describe Transition::Import::Hits do
  before do
    @businesslink_host = create :host, hostname: 'www.businesslink.gov.uk'
    create :host, hostname: 'dstl.gov.uk'
    create :host, hostname: 'education.gov.uk'
    create :host, hostname: 'www.mhra.gov.uk'
    create :host, hostname: 'hmrc.gov.uk'
    create :host, hostname: 'justice.gov.uk'
  end

  describe '.from_tsv!' do
    context 'a single import from a file with no suggested/archive URLs', testing_before_all: true do
      before do
        @import_tsv_filename = 'spec/fixtures/hits/businesslink_2012-10-14.tsv'
        Transition::Import::Hits.from_tsv!(@import_tsv_filename)
      end

      it 'has imported hits' do
        expect(Hit.count).to eq(3)
      end

      describe 'the tracking of the file via ImportedHitsFile' do
        specify { expect(ImportedHitsFile.count).to eq(1) }

        describe 'the only file' do
          subject(:file) { ImportedHitsFile.first }

          describe '#content_hash' do
            subject { super().content_hash }
            it { is_expected.to eq(Digest::SHA1.hexdigest(File.read(@import_tsv_filename))) }
          end

          describe '#filename' do
            subject { super().filename }
            it { is_expected.to eq(@import_tsv_filename) }
          end
        end
      end

      it "has not imported hits for hosts we don't know about" do
        expect(Hit.where(path: '/unknown-host')).not_to be_any
      end

      it 'imports hits with any count, ' \
         'relying on upstream processing for per-day thresholds' do
        expect(Hit.where(path: '/previously-too-few-count').any?).to be_truthy
      end

      describe 'the homepage hit' do
        subject(:hit) { Hit.where(path: '/').first }

        describe '#host' do
          subject { super().host }
          it { is_expected.to eql(@businesslink_host) }
        end

        describe '#hit_on' do
          subject { super().hit_on }
          it { is_expected.to eql(Date.new(2012, 10, 14)) }
        end

        describe '#count' do
          subject { super().count }
          it { is_expected.to eql(21) }
        end

        describe '#path' do
          subject { super().path }
          it { is_expected.to eql('/') }
        end
      end
    end

    context 'a single import from a file with bouncer-related paths', testing_before_all: true do
      before do
        Transition::Import::Hits.from_tsv!('spec/fixtures/hits/bouncer_paths.tsv')
      end

      it 'should ignore hits that are a bouncer implementation detail' do
        expect(Hit.count).to eql(1)
      end
    end

    context 'import from a file with furniture asset paths', testing_before_all: true do
      before do
        Transition::Import::Hits.from_tsv!('spec/fixtures/hits/furniture_paths.tsv')
      end

      it 'should ignore hits that are furniture so are uninteresting and unlikely to be mapped' do
        expect(Hit.pluck(:path).sort).to eql(['/index.jsp', '/legitimate'])
      end
    end

    context 'import from a file with spam paths', testing_before_all: true do
      before do
        Transition::Import::Hits.from_tsv!('spec/fixtures/hits/spam_paths.tsv')
      end

      it 'should ignore hits that are spam and so unlikely to be mapped' do
        expect(Hit.pluck(:path).sort).to eql(['/legitimate'])
      end
    end

    context 'import from a file with cruft paths', testing_before_all: true do
      before do
        Transition::Import::Hits.from_tsv!('spec/fixtures/hits/cruft_paths.tsv')
      end

      it 'should ignore hits that are cruft and so unlikely to be mapped' do
        expect(Hit.pluck(:path).sort).to eql(['/legitimate'])
      end
    end

    context 'import from a file with way-too-long paths', testing_before_all: true do
      before do
        Transition::Import::Hits.from_tsv!('spec/fixtures/hits/too_long_paths.tsv')
      end

      it 'should ignore hits that are too long and won\'t fit in our 2048-char limit' do
        expect(Hit.pluck(:path).sort).to eql(['/legitimate'])
      end
    end

    context 'a hits row already exists with a different count', testing_before_all: true do
      before do
        date = Time.utc(2012, 10, 15)
        create(:hit, host: @businesslink_host, path: '/', count: 10, http_status: '301', hit_on: date)
        Transition::Import::Hits.from_tsv!('spec/fixtures/hits/businesslink_2012-10-15.tsv')
      end

      it 'does not create a second hits row' do
        expect(Hit.count).to eql(1)
      end

      it 'updates the count for the existing row' do
        expect(Hit.first.count).to eql(21)
      end
    end

    context 'a second import' do
      let(:original_import_time) { Time.zone.parse '2014-08-15 14:59:59' }
      let(:later_import_time) { Time.zone.parse '2014-08-15 15:59:59' }
      let(:import_tsv_filename) do
        'spec/fixtures/hits/tmp_changed_hits_file.tsv'.tap do |temporary_file|
          FileUtils.cp('spec/fixtures/hits/businesslink_2012-10-14.tsv', temporary_file)
        end
      end
      let(:one_and_only_import) { ImportedHitsFile.first }

      before do
        Timecop.freeze(original_import_time)
        Transition::Import::Hits.from_tsv!(import_tsv_filename)
      end

      after do
        Timecop.return
        File.delete(import_tsv_filename)
      end

      it 'has recorded the time of the import' do
        expect(one_and_only_import.created_at).to eq(original_import_time)
        expect(one_and_only_import.updated_at).to eq(original_import_time)
      end

      context 'from an unchanged hits file' do
        before do
          Timecop.freeze(later_import_time)
          expect(Transition::Import::Hits).to receive(:console_puts).with('skipped')
          Transition::Import::Hits.from_tsv!(import_tsv_filename)
        end

        it 'leaves the record of the first import unchanged' do
          expect(one_and_only_import.created_at).to eq(original_import_time)
          expect(one_and_only_import.updated_at).to eq(original_import_time)
        end
      end

      context 'from a changed hits file' do
        before do
          @old_content_hash = ImportedHitsFile.first.content_hash

          File.open(import_tsv_filename, 'a') do |tsv|
            tsv.puts "2012-11-14\t33\t301\twww.businesslink.gov.uk\t/altered-hits"
          end

          Timecop.freeze(later_import_time)
          Transition::Import::Hits.from_tsv!(import_tsv_filename)
        end

        it 'updates the record of the first import' do
          expect(one_and_only_import.created_at).to eq(original_import_time)
          expect(one_and_only_import.updated_at).to eq(later_import_time)
          expect(one_and_only_import.content_hash).not_to eq(@old_content_hash)
        end

        it 'imports the new hits' do
          expect(Hit.where(path: '/altered-hits').first).not_to be_nil
        end
      end
    end
  end

  describe '.from_csv!' do
    context 'a csv file produced by Amazon Athena' do
      before do
        Transition::Import::Hits.from_csv!('spec/fixtures/hits/athena_hits.csv')
      end

      it 'imports the data' do
        expect(Hit.count).to eql(9)
      end

      it 'handles csv quoting' do
        expect(Hit.where(path: '/contacts/hmcts/tribunals/residential-property.htm"').first).not_to be_nil
      end
    end
  end

  describe '.from_iis_w3c!' do
    context 'when there is a host that matches the IP address' do
      it 'imports the data' do
        host = create :host, hostname: 'dev.infohub.ukri.org'

        Transition::Import::Hits.from_iis_w3c!('spec/fixtures/hits/iis_w3c_example.log')

        expect(Hit.count).to eql(1)
        hit = Hit.first
        expect(hit.path).to eql('/news/')
        expect(hit.count).to eql(3)
        expect(hit.hit_on).to eql(Date.new(2019, 9, 17))
        expect(hit.host_id).to eql(host.id)
      end
    end

    context 'when there is no matching host' do
      it 'does not create a hit record' do
        Transition::Import::Hits.from_iis_w3c!('spec/fixtures/hits/iis_w3c_example.log')
        expect(Hit.count).to eql(0)
      end
    end

    context 'when the file is unexpected' do
      it 'does not create a hit record' do
        Transition::Import::Hits.from_iis_w3c!('spec/fixtures/hits/unexpected_log_format.log')
        expect(Hit.count).to eql(0)
      end
    end

    context 'when the file is not parseable' do
      it 'does not create a hit record' do
        Transition::Import::Hits.from_iis_w3c!('spec/fixtures/hits/unknown_log_format.log')
        expect(Hit.count).to eql(0)
      end
    end
  end

  describe '.from_s3!' do
    let(:bucket) { 'bucket' }
    let(:s3) { Aws::S3::Client.new(stub_responses: true) }

    before do
      allow(Services).to receive(:s3).and_return(s3)
    end

    context 'with csv files in s3' do
      it 'loads a csv file' do
        mock_s3_response("results.csv" => 'athena_hits.csv')
        expect { Transition::Import::Hits.from_s3!(bucket) }.to change(Hit, :count).by(9)
      end

      it 'loads multiple csv files' do
        mock_s3_response(
          "results1.csv" => 'athena_hits.csv',
          "results2.csv" => 'athena_hits_more.csv',
        )
        expect { Transition::Import::Hits.from_s3!(bucket) }.to change(Hit, :count).by(21)
      end

      it 'loads a changed a csv file' do
        mock_s3_response("results.csv" => 'athena_hits.csv')
        expect { Transition::Import::Hits.from_s3!(bucket) }.to change(Hit, :count).by(9)
        mock_s3_response("results.csv" => 'athena_hits_more.csv')
        expect { Transition::Import::Hits.from_s3!(bucket) }.to change(Hit, :count).by(12)
      end

      it 'does not load an unchanged a csv file' do
        key = "results.csv"
        file = 'athena_hits.csv'

        s3.stub_responses(:list_objects, contents: [{ key: key, etag: file }])
        s3.stub_responses(:get_object, body: File.open("spec/fixtures/hits/#{file}"))

        expect(s3).to receive(:list_objects).with(bucket: bucket).twice.and_call_original
        expect(s3).to receive(:get_object).with(bucket: bucket, key: key).and_call_original
        expect { Transition::Import::Hits.from_s3!(bucket) }.to change(Hit, :count).by(9)
        expect(s3).to_not receive(:get_object).with(bucket: bucket, key: key)
        expect { Transition::Import::Hits.from_s3!(bucket) }.to_not change(Hit, :count)
      end

      it 'does not load a metadata file' do
        key = "results.csv.metadata"

        s3.stub_responses(:list_objects, contents: [{ key: key, etag: 'x' }])

        expect(s3).to receive(:list_objects).with(bucket: bucket).and_call_original
        expect(s3).to_not receive(:get_object).with(bucket: bucket, key: key)

        expect { Transition::Import::Hits.from_s3!(bucket) }.to_not change(Hit, :count)
      end
    end

    context 'with csv and tsv files in s3' do
      it 'loads each type of file' do
        mock_s3_response(
          "results1.csv" => 'athena_hits.csv',
          "results2.tsv" => 'businesslink_2012-10-14.tsv',
        )
        expect { Transition::Import::Hits.from_s3!(bucket) }.to change(Hit, :count).by(12)
      end
    end

    def mock_s3_response(contents)
      key_list = contents.map do |key, file|
        { key: key, etag: file }
      end

      s3.stub_responses(:list_objects, contents: key_list)
      s3.stub_responses(
        :get_object,
        ->(context) do
          key = context.params[:key]
          file = contents[key]
          return { body: File.open("spec/fixtures/hits/#{file}") }
        end,
      )

      expect(s3).to receive(:list_objects).with(bucket: bucket).and_call_original
      contents.each_key do |key|
        expect(s3).to receive(:get_object).with(bucket: bucket, key: key).and_call_original
      end
    end
  end

  describe '.from_mask!', testing_before_all: true do
    before do
      Transition::Import::Hits.from_mask!('spec/fixtures/hits/businesslink_*.tsv')
    end

    it 'imports hits from the combined files for the known hosts' do
      expect(Hit.count).to eq(4)
    end
  end
end

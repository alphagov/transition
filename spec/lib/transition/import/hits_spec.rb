require 'spec_helper'
require 'transition/import/hits'

describe Transition::Import::Hits do
  def create_test_hosts
    @businesslink_host = create :host, hostname: 'www.businesslink.gov.uk'
  end

  describe '.from_redirector_tsv_file!' do
    context 'a single import from a file with no suggested/archive URLs', testing_before_all: true do
      before :all do
        create_test_hosts
        @import_tsv_filename = 'spec/fixtures/hits/businesslink_2012-10-14.tsv'
        Transition::Import::Hits.from_redirector_tsv_file!(@import_tsv_filename)
      end

      it 'has imported hits' do
        Hit.count.should == 3
      end

      describe 'the tracking of the file via ImportedHitsFile' do
        specify { ImportedHitsFile.should have(1).file }

        describe 'the only file' do
          subject(:file) { ImportedHitsFile.first }

          its(:content_hash) { should == Digest::SHA1.hexdigest(File.read(@import_tsv_filename)) }
          its(:filename)     { should == File.expand_path(@import_tsv_filename) }
        end
      end

      it "has not imported hits for hosts we don't know about" do
        Hit.where(path: '/unknown-host').should_not be_any
      end

      it 'imports hits with any count, ' \
         'relying on upstream processing for per-day thresholds' do
        Hit.where(path: '/previously-too-few-count').any?.should be_true
      end

      describe 'the homepage hit' do
        subject(:hit) { Hit.where(path: '/').first }

        its(:host)      { should eql(@businesslink_host) }
        its(:hit_on)    { should eql(Date.new(2012, 10, 14)) }
        its(:count)     { should eql(21) }
        its(:path)      { should eql('/') }
        its(:path_hash) { should eql('42099b4af021e53fd8fd4e056c2568d7c2e3ffa8') }
      end
    end

    context 'a single import from a file with bouncer-related paths', testing_before_all: true do
      before :all do
        create_test_hosts
        Transition::Import::Hits.from_redirector_tsv_file!('spec/fixtures/hits/bouncer_paths.tsv')
      end

      it 'should ignore hits that are a bouncer implementation detail' do
        Hit.count.should eql(1)
      end
    end

    context 'import from a file with furniture asset paths', testing_before_all: true do
      before :all do
        create_test_hosts
        Transition::Import::Hits.from_redirector_tsv_file!('spec/fixtures/hits/furniture_paths.tsv')
      end

      it 'should ignore hits that are furniture so are uninteresting and unlikely to be mapped' do
        Hit.pluck(:path).sort.should eql(['/legitimate'])
      end
    end

    context 'import from a file with spam paths', testing_before_all: true do
      before :all do
        create_test_hosts
        Transition::Import::Hits.from_redirector_tsv_file!('spec/fixtures/hits/spam_paths.tsv')
      end

      it 'should ignore hits that are spam and so unlikely to be mapped' do
        Hit.pluck(:path).sort.should eql(['/legitimate'])
      end
    end

    context 'import from a file with cruft paths', testing_before_all: true do
      before :all do
        create_test_hosts
        Transition::Import::Hits.from_redirector_tsv_file!('spec/fixtures/hits/cruft_paths.tsv')
      end

      it 'should ignore hits that are cruft and so unlikely to be mapped' do
        Hit.pluck(:path).sort.should eql(['/legitimate'])
      end
    end

    context 'a hits row already exists with a different count', testing_before_all: true do
      before :all do
        create_test_hosts
        date = Time.utc(2012, 10, 15)
        create(:hit, host: @businesslink_host, path: '/', count: 10, http_status: '301', hit_on: date)
        Transition::Import::Hits.from_redirector_tsv_file!('spec/fixtures/hits/businesslink_2012-10-15.tsv')
      end

      it 'does not create a second hits row' do
        Hit.count.should eql(1)
      end

      it 'updates the count for the existing row' do
        Hit.first.count.should eql(21)
      end
    end

    context 'a second import' do
      let(:original_import_time) { Time.zone.parse '2014-08-15 14:59:59' }
      let(:later_import_time   ) { Time.zone.parse '2014-08-15 15:59:59' }
      let(:import_tsv_filename ) do
        'spec/fixtures/hits/tmp_changed_hits_file.tsv'.tap do |temporary_file|
          FileUtils.cp('spec/fixtures/hits/businesslink_2012-10-14.tsv', temporary_file)
        end
      end
      let(:one_and_only_import) { ImportedHitsFile.first }

      before do
        Host.delete_all; create_test_hosts
        # first import to fresh DB
        Timecop.freeze(original_import_time)
        Transition::Import::Hits.from_redirector_tsv_file!(import_tsv_filename)
      end

      after do
        Timecop.return
        File.delete(import_tsv_filename)
      end

      it 'has recorded the time of the import' do
        one_and_only_import.created_at.should == original_import_time
        one_and_only_import.updated_at.should == original_import_time
      end

      context 'from an unchanged hits file' do
        before do
          Timecop.freeze(later_import_time)
          Transition::Import::Hits.should_receive(:console_puts).with('skipped')
          Transition::Import::Hits.from_redirector_tsv_file!(import_tsv_filename)
        end

        it 'leaves the record of the first import unchanged' do
          one_and_only_import.created_at.should == original_import_time
          one_and_only_import.updated_at.should == original_import_time
        end
      end

      context 'from a changed hits file' do
        before do
          @old_content_hash = ImportedHitsFile.first.content_hash

          File.open(import_tsv_filename, 'a') do |tsv|
            tsv.puts "2012-11-14\t33\t301\twww.businesslink.gov.uk\t/altered-hits"
          end

          Timecop.freeze(later_import_time)
          Transition::Import::Hits.from_redirector_tsv_file!(import_tsv_filename)
        end

        it 'updates the record of the first import' do
          one_and_only_import.created_at.should == original_import_time
          one_and_only_import.updated_at.should == later_import_time
          one_and_only_import.content_hash.should_not == @old_content_hash
        end

        it 'imports the new hits' do
          Hit.where(path: '/altered-hits').first.should_not be_nil
        end
      end
    end
  end

  describe '.from_redirector_mask!', testing_before_all: true do
    before :all do
      create_test_hosts
      Transition::Import::Hits.from_redirector_mask!('spec/fixtures/hits/businesslink_*.tsv')
    end

    it 'imports hits from the combined files for the known hosts' do
      Hit.count.should == 4
    end
  end
end

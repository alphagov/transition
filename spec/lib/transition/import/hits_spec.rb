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
        Transition::Import::Hits.from_redirector_tsv_file!('spec/fixtures/hits/businesslink_2012-10-14.tsv')
      end

      it 'has imported hits' do
        Hit.count.should == 2
      end

      it "has not imported hits for hosts we don't know about" do
        Hit.where(path: '/unknown-host').any?.should be_false
      end

      it 'has not imported hits with a count less than ten' do
        Hit.where(path: '/too-few-count').any?.should be_false
      end

      describe 'the first hit' do
        subject(:hit) { Hit.first }

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
  end

  describe '.from_redirector_mask!', testing_before_all: true do
    before :all do
      create_test_hosts
      Transition::Import::Hits.from_redirector_mask!('spec/fixtures/hits/businesslink_*.tsv')
    end

    it 'imports hits from the combined files for the known hosts' do
      Hit.count.should == 3
    end
  end
end

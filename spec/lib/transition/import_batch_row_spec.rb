require 'spec_helper'

describe Transition::ImportBatchRow do
  def make_a_row(old_value, new_value=nil)
    line_number = 1
    Transition::ImportBatchRow.new(site, line_number, [old_value, new_value])
  end

  def make_a_row_with_line_number(line_number, old_value, new_value=nil)
    Transition::ImportBatchRow.new(site, line_number, [old_value, new_value])
  end

  let(:site) { build :site, query_params: 'significant' }

  describe 'initializer' do
    it 'should strip leading and trailing whitespace' do
      row = make_a_row(' a ', " b\t")
      row.old_value.should == 'a'
      row.new_value.should == 'b'
    end

    it 'should strip the old value' do
      row = make_a_row('  ', nil)
      row.old_value.should eql('')
    end

    it 'should turn a blank new value to nil' do
      row = make_a_row('', " \t")
      row.new_value.should be_nil
    end
  end

  describe 'data_row?' do
    it 'rejects random headings' do
      row = make_a_row('   URLs   ', nil)
      row.data_row?.should be_false
    end

    it 'accepts rows with leading whitespace' do
      row = make_a_row(' /a', nil)
      row.data_row?.should be_true
    end

    it 'accepts rows with http' do
      row = make_a_row(' http', nil)
      row.data_row?.should be_true
    end
  end

  describe 'type' do
    it 'should be an archive if the new_value is "TNA"' do
      row = make_a_row('', 'TNA')
      row.type.should == 'archive'
    end

    it 'should be an archive regardless of the case of "TNA"' do
      row = make_a_row('', 'tNa')
      row.type.should == 'archive'
    end

    it 'should not be an archive when the new URL contains "TNA"' do
      row = make_a_row('', 'http://a.com/antna')
      row.type.should == 'redirect'
    end

    it 'should be unresolved when the new URL is blank' do
      row = make_a_row('', ' ')
      row.type.should == 'unresolved'
    end
  end

  describe 'path' do
    context 'the old value is empty' do
      it 'should keep the path as just a path' do
        row = make_a_row('', nil)
        row.path.should == ''
      end
    end

    context 'the old value is just a path' do
      it 'should keep the path as just a path' do
        row = make_a_row('/old', nil)
        row.path.should == '/old'
      end
    end

    context 'the old value is an absolute URL' do
      it 'should set the path to just the path' do
        row = make_a_row('http://foo.com/old', nil)
        row.path.should == '/old'
      end
    end

    describe 'canonicalization' do
      it 'should canonicalize the path' do
        row = make_a_row('http://foo.com/old?significant=keep&insignificant=drop', nil)
        row.path.should == '/old?significant=keep'
      end
    end
  end

  describe 'new_url' do
    it 'should return the new_value if it is a redirect' do
      row = make_a_row('', 'http://a.com')
      row.new_url.should == 'http://a.com'
    end

    it 'should return nil if it is not a redirect' do
      row = make_a_row('', 'TNA')
      row.new_url.should be_nil
    end
  end

  describe '<=> - comparison for being able to sort mappings for the same Old URL' do
    let(:redirect)       { make_a_row('/old', 'https://a.gov.uk/new') }
    let(:later_redirect) { make_a_row_with_line_number(2, '/old', 'https://a.gov.uk/later') }
    let(:archive)        { make_a_row('/old', 'TNA') }
    let(:unresolved)     { make_a_row('/old') }

    context 'comparing rows for different paths' do
      it 'raises an error' do
        different_path = make_a_row('/different')
        expect{ redirect > different_path }.to raise_error(ArgumentError)
      end
    end

    context 'a redirect' do
      it 'trump an archive' do
        redirect.should > archive
        archive.should < redirect
      end

      it 'trumps an unresolved' do
        redirect.should > unresolved
        unresolved.should < redirect
      end

      it 'trumps a later redirect' do
        redirect.should > later_redirect
        later_redirect.should < redirect
      end
    end

    context 'an archive' do
      it 'trumps an unresolved' do
        archive.should > unresolved
        unresolved.should < archive
      end
    end
  end
end

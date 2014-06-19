require 'spec_helper'

describe Transition::ImportBatchRow do
  def make_a_row(old_value, new_value=nil)
    Transition::ImportBatchRow.new(site, old_value, new_value)
  end

  let(:site) { build :site, query_params: 'significant' }

  describe 'initializer' do
    it 'should strip leading and trailing whitespace' do
      row = make_a_row(' a ', " b\t")
      row.old_value.should == 'a'
      row.new_value.should == 'b'
    end

    it 'should turn empty strings to nil' do
      row = make_a_row('  ', " \t")
      row.old_value.should be_nil
      row.new_value.should be_nil
    end

    it 'should turn nils to nils (and not raise an error)' do
      row = make_a_row(nil, nil)
      row.old_value.should be_nil
      row.new_value.should be_nil
    end
  end

  describe 'type' do
    it 'should be an archive if the new_value is "TNA"' do
      row = make_a_row(nil, 'TNA')
      row.type.should == 'archive'
    end

    it 'should be an archive regardless of the case of "TNA"' do
      row = make_a_row(nil, 'tNa')
      row.type.should == 'archive'
    end

    it 'should not be an archive when the new URL contains "TNA"' do
      row = make_a_row(nil, 'http://a.com/antna')
      row.type.should == 'redirect'
    end

    it 'should be unresolved when the new URL is blank' do
      row = make_a_row(nil, ' ')
      row.type.should == 'unresolved'
    end
  end

  describe 'path' do
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
      row = make_a_row(nil, 'http://a.com')
      row.new_url.should == 'http://a.com'
    end

    it 'should return nil if it is not a redirect' do
      row = make_a_row(nil, 'TNA')
      row.new_url.should be_nil
    end
  end

  describe '<=> - comparison for being able to sort mappings for the same Old URL' do
    let(:redirect)   { make_a_row('/redirect-me', 'https://a.gov.uk/new') }
    let(:archive)    { make_a_row('/archive-me', 'TNA') }
    let(:unresolved) { make_a_row('/unresolved-me') }

    context 'a redirect' do
      it 'trump an archive' do
        redirect.should > archive
        archive.should < redirect
      end

      it 'trumps an unresolved' do
        redirect.should > unresolved
        unresolved.should < redirect
      end

      it 'trumps a later redirect'
    end

    context 'an archive' do
      it 'trumps an unresolved' do
        archive.should > unresolved
        unresolved.should < archive
      end
    end
  end
end

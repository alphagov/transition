require 'spec_helper'

describe Transition::ImportBatchRow do
  describe 'initializer' do
    it 'should strip leading and trailing whitespace' do
      row = Transition::ImportBatchRow.new(' a ', " b\t")
      row.old_value.should == 'a'
      row.new_value.should == 'b'
    end

    it 'should turn empty strings to nil' do
      row = Transition::ImportBatchRow.new('  ', " \t")
      row.old_value.should be_nil
      row.new_value.should be_nil
    end

    it 'should turn nils to nils (and not raise an error)' do
      row = Transition::ImportBatchRow.new(nil, nil)
      row.old_value.should be_nil
      row.new_value.should be_nil
    end
  end

  describe 'type' do
    it 'should be an archive if the new_value is "TNA"' do
      row = Transition::ImportBatchRow.new(nil, 'TNA')
      row.type.should == 'archive'
    end

    it 'should be an archive regardless of the case of "TNA"' do
      row = Transition::ImportBatchRow.new(nil, 'tNa')
      row.type.should == 'archive'
    end

    it 'should not be an archive when the new URL contains "TNA"' do
      row = Transition::ImportBatchRow.new(nil, 'http://a.com/antna')
      row.type.should == 'redirect'
    end

    it 'should be unresolved when the new URL is blank' do
      row = Transition::ImportBatchRow.new(nil, ' ')
      row.type.should == 'unresolved'
    end
  end

  describe 'path' do
    context 'the old value is just a path' do
      it 'should keep the path as just a path' do
        row = Transition::ImportBatchRow.new('/old', nil)
        row.path.should == '/old'
      end
    end

    context 'the old value is an absolute URL' do
      it 'should set the path to just the path' do
        row = Transition::ImportBatchRow.new('http://foo.com/old', nil)
        row.path.should == '/old'
      end
    end
  end

  describe 'new_url' do
    it 'should return the new_value if it is a redirect' do
      row = Transition::ImportBatchRow.new(nil, 'http://a.com')
      row.new_url.should == 'http://a.com'
    end

    it 'should return nil if it is not a redirect' do
      row = Transition::ImportBatchRow.new(nil, 'TNA')
      row.new_url.should be_nil
    end
  end
end

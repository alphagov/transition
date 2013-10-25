require 'spec_helper'

describe Transition::Hits::Category do
  describe '.all' do
    subject(:all_categories) { Transition::Hits::Category.all }

    it { should be_an(Array)}
    it { should have(5).categories }

    describe 'the first' do
      subject { Transition::Hits::Category.all.first }

      it { should be_a(Transition::Hits::Category) }

      its(:title)  { should == 'All' }
      its(:to_sym) { should == :all }
      its(:color)  { should == '#999' }
    end

    describe 'indexing' do
      subject { Transition::Hits::Category['errors'] }

      its(:title)  { should == 'Errors' }
      its(:to_sym) { should == :errors }
      its(:color)  { should == '#e99' }
    end
  end
end

require 'spec_helper'

describe Hit do
  describe 'relationships' do
    it { should belong_to(:host) }
  end

  describe 'validations' do
    it { should validate_presence_of(:host) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:path_hash) }
    it { should validate_presence_of(:count) }
    it { should validate_numericality_of(:count).is_greater_than_or_equal_to(0) }
  end

  describe 'attributes set before validation' do
    subject { create :hit, hit_on: DateTime.new(2014, 12, 31, 23, 59, 59) }

    its(:hit_on)    { should eql(DateTime.new(2014, 12, 31, 0, 0, 0)) }
    its(:path_hash) { should eql('ce81157034ae8c32f429d3dc03bed10cc0c47b65') }
  end

  describe '#homepage?' do
    specify { create(:hit, path: '/').homepage?.should be_true }
    specify { create(:hit, path: '/?q=1').homepage?.should be_true }
    specify { create(:hit, path: '/foo').homepage?.should be_false }
  end
end

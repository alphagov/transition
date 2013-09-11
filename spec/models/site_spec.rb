require 'spec_helper'

describe Site do
  describe 'relationships' do
    it { should belong_to(:organisation) }
    it { should have_many(:hosts) }
    it { should have_many(:mappings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:abbr) }
    it { should validate_uniqueness_of(:abbr) }
  end
end

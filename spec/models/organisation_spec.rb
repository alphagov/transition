require 'spec_helper'

describe Organisation do
  describe 'relationships' do
    it { should have_many(:sites) }
    it { should have_many(:hosts).through(:sites) }
    it { should have_many(:mappings).through(:sites) }
  end

  describe 'validations' do
    it { should validate_presence_of(:redirector_abbr) }
    it { should validate_uniqueness_of(:redirector_abbr) }
  end
end

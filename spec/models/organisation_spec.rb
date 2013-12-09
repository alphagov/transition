require 'spec_helper'

describe Organisation do
  describe 'relationships' do
    it { should have_many(:sites) }
    it { should have_many(:hosts).through(:sites) }
    it { should have_many(:mappings).through(:sites) }
  end

  describe 'validations' do
    it { should validate_presence_of(:whitehall_slug) }
    it 'ensures whitehall_slugs are unique' do
      create :organisation
      should validate_uniqueness_of(:whitehall_slug)
    end
  end
end

require 'spec_helper'

describe MappingsBatch do
  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:site) }
    it { should ensure_inclusion_of(:state).in_array(MappingsBatch::PROCESSING_STATES) }
  end
end

require 'spec_helper'

describe MappingsBatchEntry do
  describe 'relationships' do
    it { should belong_to(:mappings_batch) }
    it { should belong_to(:mapping) }
  end
end

require "rails_helper"

describe MappingsBatchEntry do
  describe "relationships" do
    it { is_expected.to belong_to(:mappings_batch) }
    it { is_expected.to belong_to(:mapping) }
  end
end

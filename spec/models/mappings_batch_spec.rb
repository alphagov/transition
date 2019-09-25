require "rails_helper"

describe MappingsBatch do
  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:site) }
    it { is_expected.to validate_inclusion_of(:state).in_array(MappingsBatch::PROCESSING_STATES) }
  end
end

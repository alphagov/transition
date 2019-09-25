require "rails_helper"

describe ImportedHitsFile do
  describe "validations" do
    it { is_expected.to validate_presence_of(:filename) }
    it { is_expected.to validate_uniqueness_of(:filename) }
    it { is_expected.to validate_presence_of(:content_hash) }
  end
end

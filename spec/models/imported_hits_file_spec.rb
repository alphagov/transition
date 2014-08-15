require 'spec_helper'

describe ImportedHitsFile do
  describe 'validations' do
    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:content_hash) }
  end
end

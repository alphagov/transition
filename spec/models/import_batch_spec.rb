require 'spec_helper'

describe ImportBatch do
  describe 'disabled fields' do
    it 'should prevent access to fields which are irrelevant to this subclass' do
      expect{ ImportBatch.new.type }.to raise_error(NoMethodError)
      expect{ ImportBatch.new.new_url }.to raise_error(NoMethodError)
    end
  end
end

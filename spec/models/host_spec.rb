require 'spec_helper'

describe Host do
  describe 'relationships' do
    it { should belong_to(:site) }
  end
end
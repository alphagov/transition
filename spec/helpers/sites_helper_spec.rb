require 'spec_helper'

describe SitesHelper do
  describe '#days_before_or_after_launch' do
    let(:site) { double('site') }
    it do
      site.
      Timecop.travel Date.new(2000, 1, 1)

    end
  end
end

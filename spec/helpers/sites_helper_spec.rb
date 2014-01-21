require 'spec_helper'

describe SitesHelper do
  describe '#big_launch_days_number' do
    let(:site)      { double('site') }
    let(:halloween) { Date.new(2013, 10, 31) }

    before do
      Timecop.freeze(halloween)
      site.stub(:launch_date).and_return(launch_date)
    end

    subject { helper.big_launch_days_number(site) }

    context 'when launching in the future' do
      let(:launch_date) { Date.new(2013, 11, 14) }
      it { should include('days') }
      it { should include('until transition') }
    end

    context 'when launching in the past' do
      let(:launch_date) { Date.new(2013, 10, 29) }
      it { should include('days') }
      it { should include('since transition') }
    end

    context 'when launched yesterday' do
      let(:launch_date) { Date.new(2013, 10, 30) }
      it { should include('day')}
      it { should include('since transition')}
    end

    context 'when launching tomorrow' do
      let(:launch_date) { Date.new(2013, 11, 1) }
      it { should include('day')}
      it { should include('until transition')}
    end
  end
end

require 'spec_helper'

describe SitesHelper do
  describe '#big_launch_days_number' do
    let(:site)      { double('site') }
    let(:halloween) { Date.new(2013, 10, 31) }

    before do
      Timecop.freeze(halloween)
      site.stub(:launch_date).and_return(launch_date)
      site.stub(:transition_status).and_return(transition_status)
    end

    subject { helper.big_launch_days_number(site) }

    context 'when launch date is not set' do
      let(:launch_date)       { nil }
      let(:transition_status) { :pre_transition }

      it { should be_nil }
    end

    context 'when launching 14 days in the future' do
      let(:launch_date)       { Date.new(2013, 11, 14) }
      let(:transition_status) { :pre_transition }
      it { should include('14 days') }
      it { should include('until transition') }
    end

    context 'when launched 2 days ago' do
      let(:launch_date) { Date.new(2013, 10, 29) }
      let(:transition_status) { :live }
      it { should include('2 days') }
      it { should include('since transition') }
    end

    context 'when launched yesterday' do
      let(:launch_date) { Date.new(2013, 10, 30) }
      let(:transition_status) { :live }

      it { should include('1 day')}
      it { should include('since transition')}
    end

    context 'when launching tomorrow' do
      let(:launch_date) { Date.new(2013, 11, 1) }
      let(:transition_status) { :pre_transition }
      it { should include('1 day')}
      it { should include('until transition')}
    end

    context 'the site was supposed to launch but its transition_status is pre-transition' do
      let(:launch_date)       { Date.new(2013, 10, 1) }
      let(:transition_status) { :pre_transition }
      it { should include('30 days') }
      it { should include('overdue') }
    end
  end
end

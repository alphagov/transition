require 'spec_helper'
require 'transition/import/hits/precompute'

describe Transition::Import::Hits::Precompute do
  let(:new_precompute_value) { false }

  subject(:precompute_setter) do
    Transition::Import::Hits::Precompute.new(abbrs, new_precompute_value)
  end

  before do
    # We only care about certain console messages. Don't
    # let rspec-mocks bully us about the others.
    precompute_setter.console.as_null_object
  end

  describe '#update!' do
    context 'the sites we are updating do not exist' do
      let(:abbrs) { ['foobar', 'baz', '', ''] }

      it 'updates nothing and warns about what it could not find' do
        precompute_setter.console.should_receive(:puts).with(
          "WARN: skipping site with abbr 'foobar' - not found")
        precompute_setter.console.should_receive(:puts).with(
          "WARN: skipping site with abbr 'baz' - not found")

        precompute_setter.update!.should be_zero
      end
    end

    context 'we are updating two sites, one non-existent, and one already set' do
      let(:abbrs)                { %w(hmrc ofsted already_set throat_wobbler_mangrove) }
      let(:new_precompute_value) { true }

      before do
        create(:site, abbr: 'hmrc', precompute_all_hits_view: false)
        create(:site, abbr: 'ofsted', precompute_all_hits_view: false)
        create(:site, abbr: 'already_set', precompute_all_hits_view: true)
      end

      it 'updates two, warns about the others, and reminds us to refresh' do
        precompute_setter.console.should_receive(:puts).with(
          "WARN: skipping site with abbr 'throat_wobbler_mangrove' - not found")
        precompute_setter.console.should_receive(:puts).with(
          "WARN: skipping site with abbr 'already_set' - already set to true")
        precompute_setter.should_receive(:inform_about_refresh)
        precompute_setter.update!.should == 2
      end
    end

    context 'we are updating a site not to precompute' do
      let(:abbrs)                { ['hmrc'] }
      let(:new_precompute_value) { false }

      before do
        create(:site, abbr: 'hmrc', precompute_all_hits_view: true)
      end

      it 'updates one, and does not remind us to refresh' do
        precompute_setter.should_not receive(:inform_about_refresh)
        precompute_setter.update!.should == 1
      end
    end
  end
end

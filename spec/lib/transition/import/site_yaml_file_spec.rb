require 'spec_helper'
require 'transition/import/site_yaml_file'

describe Transition::Import::SiteYamlFile do
  context 'A redirector YAML file' do
    subject(:redirector_yaml_file) do
      Transition::Import::SiteYamlFile.load('spec/fixtures/sites/someyaml/ago.yml')
    end

    its(:abbr)           { should eql 'ago' }
    its(:whitehall_slug) { should eql 'attorney-generals-office' }
    it 'is not managed by transition - it doesn\'t have transition-sites in path' do
      redirector_yaml_file.should_not be_managed_by_transition
    end
  end

  context 'A transition YAML file' do
    subject(:transition_yaml_file) do
      Transition::Import::SiteYamlFile.load('spec/fixtures/sites/someyaml/transition-sites/ukti.yml')
    end

    its(:abbr)           { should eql 'ukti' }
    its(:whitehall_slug) { should eql 'uk-trade-investment' }

    it 'is managed by transition - it has transition-sites in path' do
      transition_yaml_file.should be_managed_by_transition
    end
  end
end

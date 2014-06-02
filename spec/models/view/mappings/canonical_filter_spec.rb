require 'spec_helper'

module View
  module Mappings
    describe '.canonical_filter' do
      let(:site)     { build :site }

      subject(:filter) { View::Mappings.canonical_filter(site, user_input) }

      context 'when a non-path substring is given' do
        let(:user_input) { 'About?q=1' }
        it 'returns the canonicalized substring' do
          filter.should == 'about'
        end
      end

      context 'when a path string is given' do
        let(:user_input) { '/About?q=1' }
        it 'canonicalizes as expected' do
          filter.should == '/about'
        end
      end

      context 'when an https URL string is given' do
        let(:user_input) { 'https://www.example.com/About?q=1' }
        it 'canonicalizes as expected' do
          filter.should == '/about'
        end
      end

      context 'when an http URL string is given' do
        let(:user_input) { 'http://www.example.com/About?q=1' }
        it 'canonicalizes as expected' do
          filter.should == '/about'
        end
      end

      context 'when an unparseable URL string is given' do
        let(:user_input) { 'https://}}}?q=1' }
        it 'returns the string unadulterated' do
          filter.should == 'https://}}}?q=1'
        end
      end

      context 'when a trailing slash is given' do
        let(:user_input) { '/A/' }
        it 'canonicalizes, but leaves them alone' do
          filter.should == '/a/'
        end
      end

      context 'a blank string is given' do
        let(:user_input) { '' }
        it { should be_nil }
      end

      context 'nil is given' do
        let(:user_input) { nil }
        it { should be_nil }
      end
    end
  end
end

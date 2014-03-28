require 'spec_helper'

describe Transition::OffSiteRedirectChecker do
  describe 'on_site?' do
    subject do
      Transition::OffSiteRedirectChecker.on_site?(location)
    end

    context 'genuine path' do
      let(:location) { '/a/path' }
      it { should == true }
    end

    context 'absolute URI' do
      let(:location) { 'http://malicious.com' }
      it { should == false }
    end

    context 'triple leading slash' do
      let(:location) { '///malicious.com' }
      it { should == false }
    end

    context 'protocol-relative URL' do
      let(:location) { '//malicious.com' }
      it { should == false }
    end

    context 'nil' do
      let(:location) { nil }
      it { should == false }
    end
  end
end

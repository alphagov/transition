require 'spec_helper'

describe Host do
  describe 'relationships' do
    it { should belong_to(:site) }
  end

  describe '#aka_hostname' do
    let(:host) { build(:host, hostname: @hostname) }
    subject(:aka_hostname) { host.aka_hostname }

    it "should add aka- on the front if no www" do
      @hostname = 'foo.com'
      aka_hostname.should eql('aka-foo.com')
    end

    it "should replace www. with aka. " do
      @hostname = 'www.foo.com'
      aka_hostname.should eql('aka.foo.com')
    end
  end
end

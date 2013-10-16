require 'spec_helper'

describe HitsHelper do
  describe '#link_to_hit' do
    let(:hit) { build :hit }
    specify { helper.link_to_hit(hit).should =~ %r(<a href="http://.*example\.gov\.uk/article/123">/article/123</a>) }
  end
end

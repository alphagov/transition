require 'spec_helper'

describe OrganisationsHelper do
  describe '#date_or_not_yet' do
    specify { helper.date_or_not_yet(nil).should == 'Not yet launched' }
    specify { helper.date_or_not_yet(Date.new(2014)).should == 'January 1st, 2014' }
  end
end

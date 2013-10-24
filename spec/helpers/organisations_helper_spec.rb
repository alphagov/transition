require 'spec_helper'

describe OrganisationsHelper do
  describe '#date_or_not_yet' do
    specify { helper.date_or_not_yet(nil).should == 'Not yet launched' }
    specify { helper.date_or_not_yet(Date.new(2014)).should == 'January 1st, 2014' }
  end

  describe '#add_indefinite_article' do
    specify { helper.add_indefinite_article('non-departmental body').should == 'a non-departmental body' }
    specify { helper.add_indefinite_article('advisory non-departmental body').should == 'an advisory non-departmental body' }
  end

  describe '#relationship_display_name' do
    let(:executive_body) { create :organisation }
    let(:other)          { create :organisation, whitehall_type: 'Other' }

    specify { helper.relationship_display_name(executive_body).should == 'is an executive non-departmental public body of' }
    specify { helper.relationship_display_name(other).should == 'works with' }
  end
end

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

  describe '#links_to_all_parents' do
    let!(:org) { create :organisation }

    subject(:all_links) { helper.links_to_all_parents(org) }

    context 'no parents' do
      it { should eql('') }
    end

    context 'one parent' do
      let!(:parent_1) { create :organisation }
      before do
        org.parent_organisations << parent_1
      end

      it 'should be a link to the only parent' do
        expected = link_to parent_1.title, organisation_path(parent_1)
        all_links.should { eql(expected) }
      end
    end

    context 'two parents' do
      let!(:parent_1) { create :organisation }
      let!(:parent_2) { create :organisation }
      before do
        org.parent_organisations << [parent_1, parent_2]
      end

      it 'should be two links to the parents, separated by and' do
        expected = link_to parent_1.title, organisation_path(parent_1)
        expected += ' and '
        expected += link_to parent_2.title, organisation_path(parent_2)
        all_links.should { eql(expected) }
      end
    end

    context 'three parents' do
      let!(:parent_1) { create :organisation }
      let!(:parent_2) { create :organisation }
      let!(:parent_3) { create :organisation }
      before do
        org.parent_organisations << [parent_1, parent_2, parent_3]
      end

      it 'should be three links to all the parents, separated by , and' do
        expected = link_to parent_1.title, organisation_path(parent_1)
        expected += ', '
        expected += link_to parent_2.title, organisation_path(parent_2)
        expected += ' and '
        expected += link_to parent_3.title, organisation_path(parent_3)
        all_links.should { eql(expected) }
      end
    end
  end
end

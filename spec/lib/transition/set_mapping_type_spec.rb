require 'spec_helper'

describe Transition::SetMappingType do
  describe 'set_type!', testing_before_all: true do
    before :all do
      create :archived
      create :redirect
      pending_content = create :redirect
      # This is not currently a valid mapping type, but we have a few in the
      # production database which were imported from Redirector:
      pending_content.update_column(:http_status, '418')
      # Set each mapping's type to its initial value as it will be just after
      # the column is added, bypassing validation (which would set it back again):
      Mapping.all.each { |m| m.update_column(:type, '') }

      Transition::SetMappingType.set_type!
    end

    it "should set an archived mapping's type to 'archive'" do
      Mapping.where(http_status: '410').first.type.should == 'archive'
    end

    it "should set a redirect mapping's type to 'redirect'" do
      Mapping.where(http_status: '301').first.type.should == 'redirect'
    end

    # We don't support pending content mappings at the moment, but should
    # preserve the fact that some mappings already have this http_status as they
    # were imported from Redirector:
    it "should set a pending content mapping's type to 'pending_content'" do
      Mapping.where(http_status: '418').first.type.should == 'pending_content'
    end
  end
end

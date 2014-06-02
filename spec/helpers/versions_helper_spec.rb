#encoding: utf-8
require 'spec_helper'

describe VersionsHelper do
  describe '#friendly_field_name' do
    specify { helper.friendly_field_name('type').should == 'Type' }

    specify { helper.friendly_field_name('archive_url').should == 'Alternative Archive URL' }

    specify { helper.friendly_field_name('miscellaneous').should == 'Miscellaneous' }
  end

  describe '#friendly_changeset_title_for_type' do
    specify { helper.friendly_changeset_title_for_type('archive').should == 'Switched mapping to an Archive' }

    specify { helper.friendly_changeset_title_for_type('redirect').should == 'Switched mapping to a Redirect' }

    specify { helper.friendly_changeset_title_for_type('foo').should == 'Switched mapping type' }
  end

  describe '#friendly_changeset_title' do
    specify { helper.friendly_changeset_title({'id' => 1}).should == 'Mapping created' }

    specify { helper.friendly_changeset_title({'archive_url' => 1}).should == 'Alternative Archive URL updated' }

    specify { helper.friendly_changeset_title({'miscellaneous' => 1}).should == 'Miscellaneous updated' }

    specify { helper.friendly_changeset_title({'archive_url' => 1, 'miscellaneous' => 1}).should == 'Multiple properties updated' }

    specify { helper.friendly_changeset_title({'type' => ['redirect', 'archive']}).should == 'Switched mapping to an Archive' }
  end

  describe '#friendly_changeset_old_to_new' do
    specify { helper.friendly_changeset_old_to_new('misc', ['old', 'new']).should == 'old → new' }

    specify { helper.friendly_changeset_old_to_new('misc', ['', 'new']).should == '<blank> → new' }

    specify { helper.friendly_changeset_old_to_new('type', ['archive', 'redirect']).should == 'Archive → Redirect' }

    specify { helper.friendly_changeset_old_to_new('type', ['', 'redirect']).should == '<blank> → Redirect' }
  end
end
